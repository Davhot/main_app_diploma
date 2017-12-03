# TODO: рефакторинг
# 1. Вынести методы в модели
# 2. Сделать локализацию дат в locales/
# 3. Добавить 3 контроллера, унаследованные от текущего: 1. Nginx 2. Rails 3. System и вынести методы туда
# 4. Общие методы вынести в даный контроллер
# TODO: ускорение:
# Сделать модели за час и день для System и накапливать в них значения
# TODO: доделать
# 1. Фильтры на Rails график
# 2. Показ кусок Nginx лога по IP или посетителю (сейчас все IP за указанный период)

class HotCatchAppsController < ApplicationController
  # TODO: разбить на 3 контроллера: логи Rails, Nginx и сервера
  before_action :set_hot_catch_app, except: [:index]

  before_action -> {redirect_if_not_one_of_role_in ["admin"]}

  include FormatDates

  def show_all_graphs
    gon.all_graphs_path = load_all_graphs_hot_catch_app_path(@hot_catch_app)
  end

  def load_all_graphs
    @step = params["all_graphs_step"].present? ? params["all_graphs_step"] : "hour"
    @from = params["all_graphs_from"].present? ? params["all_graphs_from"] : nil
    @to = params["all_graphs_to"].present? ? params["all_graphs_to"] : nil

    @network_links, @network_x_y = Network.get_data_graph(@hot_catch_app, @step, @from, @to) # Networks
    @x_main_metric, @y_main_metric = SystemMetric.get_data_graph(@hot_catch_app, @step, @from, @to) # MainMetrics
    @x_nginx, @y_nginx = MainHotCatchLog.get_nginx_data_graph(@hot_catch_app, @step, @from, @to) # Nginx
    @x_rails, @y_rails = UserRequest.get_data_graph(@hot_catch_app, @step, @from, @to) # Rails

    @links = @network_links.dup
    @graph_arrays = @network_x_y.dup

    @y_main_metric.each{|x| @links << [x[0], @x_main_metric[0]]; @graph_arrays << x}
    @graph_arrays << @x_main_metric
    @links << [@y_nginx[0], @x_nginx[0]]; @graph_arrays << @x_nginx; @graph_arrays << @y_nginx
    @links << [@y_rails[0], @x_rails[0]]; @graph_arrays << @x_rails; @graph_arrays << @y_rails

    str = "Networks\n" + @network_links.inspect + "\n\n" + @network_x_y.inspect + "\n\n\n"
    str += "MainMetrics\n" + @x_main_metric.inspect + "\n\n" + @y_main_metric.inspect + "\n\n\n"
    str += "Nginx\n" + @x_nginx.inspect + "\n\n" + @y_nginx.inspect + "\n\n\n"
    str += "Rails\n" + @x_rails.inspect + "\n\n" + @y_rails.inspect + "\n\n\n"
    str += "Rails\n" + @links.inspect + "\n\n" + @graph_arrays.inspect + "\n\n\n"
    # raise str

    render :load_all_graphs, :layout => false
  end
  # ============================================================================
  # Ajax получение данных лога по клику на точку графика
  def nginx_logs
    parser = ParseNginx.new
    if params["nginx-date"].present?
      parser.parse_file_for_date("log/apps/#{@hot_catch_app.name.downcase}-nginx.access.log", params["nginx-date"])
      render :json => { :status => true, :nginx_logs => parser.data.map{|x| {log: x}} }
    else
      render :json => { :status => true, :nginx_logs => {log: "Нет данных"} }
    end
  end

  # Ajax подгрузка графика
  def load_nginx_graph
    parser = ParseNginx.new
    parser.parse_all_data("log/apps/#{@hot_catch_app.name.downcase}-nginx.access.log")
    @data = parser.data
    @ips = @data.map{|x| x[0]}.uniq
    @visitors = @data.map{|x| [x[0], "#{x[0]}|#{x[2]}"]}.uniq

    if params["nginx_graph_form_type"].present?
      @cur_ip = params["nginx_graph_form_ip"] if params["nginx_graph_form_ip"].present?
      @cur_visitor = params["nginx_graph_form_visitor"] if params["nginx_graph_form_visitor"].present?
      if params["nginx_graph_form_type"] == "ip" && params["nginx_graph_form_ip"].present?
        @data = @data.select{|x| x[0] == params["nginx_graph_form_ip"]}
      elsif params["nginx_graph_form_type"] == "visitor" && params["nginx_graph_form_visitor"].present?
        ip, visitor_info = params["nginx_graph_form_visitor"].split("|")
        @data = @data.select{|x| x[0] == ip && x[2] == visitor_info}
      end
    end
    @min_date = l @data.first[1]
    @max_date = l @data.last[1]
    # Берём логи за определённый промежуток времени
    if params["nginx_graph_form_from"].present?
      @begin_date = DateTime.strptime(params["nginx_graph_form_from"], format_show_datetime("minute"))
      @data = @data.select{|x| x[1] > @begin_date }
    end
    if params["nginx_graph_form_to"].present?
      @end_date = DateTime.strptime(params["nginx_graph_form_to"], format_show_datetime("minute"))
      @data = @data.select{|x| x[1] < @end_date }
    end

    @nginx_logs_path = nginx_logs_hot_catch_app_url(@hot_catch_app)
    @nginx_graph_form_step = params["nginx_graph_form_step"].present? ? params["nginx_graph_form_step"] : "hour"

    @moment_format = format_moment(@nginx_graph_form_step)
    @parse_c3_date_format = format_c3_date(@nginx_graph_form_step)
    @show_datetime_format = format_show_datetime(@nginx_graph_form_step)

    @graphic_stats = @data.map{|x| x[1].strftime(@parse_c3_date_format)}.group_by{|e| e}.map{|k, v| [k, v.length]}
    @graph_data_x = @graphic_stats.map{|x| x[0]} # DATE
    @graph_data_y = @graphic_stats.map{|x| x[1]} # COUNT REQUESTS

    if @begin_date.present? && @end_date.present? && @begin_date > @end_date
      @error_date = true
    else
      @begin_date = (@begin_date.blank? ? DateTime.strptime(@graph_data_x.first, format_c3_date(@nginx_graph_form_step)) \
        : @begin_date).strftime(format_show_datetime("minute"))

      @end_date = (@end_date.blank? ? DateTime.strptime(@graph_data_x.last, format_c3_date(@nginx_graph_form_step)) \
        : @end_date).strftime(format_show_datetime("minute"))
    end

    render :load_nginx_graph, :layout => false
  end

  def show_nginx_graph
    gon.nginx_load_graph_path = load_nginx_graph_hot_catch_app_url(@hot_catch_app)
  end

  def show_nginx_statistic
    o_file = "log/apps/#{@hot_catch_app.name.downcase}-report.json"
    # o_file = "log/apps/dummy-report2.json"
    if File.exist? o_file
      @data = JSON.parse(File.open(o_file, 'r'){|file| file.read})
      @general = @data["general"]
      @visitors = @data["visitors"]
      @requests = @data["requests"]
      @static_requests = @data["static_requests"]
      @hosts = @data["hosts"]
      @os = @data["os"]
      @browsers = @data["browsers"]
      @visit_time = @data["visit_time"]
      @status_codes = @data["status_codes"]
      @geolocation = @data["geolocation"]
    else
      flash[:danger] = "Статистика не найдена"
      redirect_to hot_catch_apps_path
    end
  end
  # ============================================================================

  # ============================================================================
  def load_network_graph
    @min_date = Network.where(hot_catch_app_id: @hot_catch_app.id)
      .order(:get_time).first.get_time.change(:offset => DateTime.now.zone).utc
    @max_date = Network.where(hot_catch_app_id: @hot_catch_app.id)
      .order(:get_time).last.get_time.change(:offset => DateTime.now.zone).utc
    # Настройки ============
    if params[:network_metric_form_step].blank?
      @step_metric = "hour"
      @show_time = true
    else
      @step_metric = params[:network_metric_form_step]
    end

    if params[:network_metric_graph_form_from].present?
      @begin_date = DateTime.strptime(params[:network_metric_graph_form_from],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @begin_date = @min_date
    end

    if params[:network_metric_graph_form_to].present?
      @end_date = DateTime.strptime(params[:network_metric_graph_form_to],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @end_date = @max_date
    end
    # ======================

    case @step_metric
    when "month"
      @format_date = ("%m.%Y")
    when "day"
      @format_date = ("%D")
    when "hour"
      @format_date = ("%D %H")
      @show_time = true
    else
      @format_date = ("%D %H:%M")
      @show_time = true
    end

    @name_networks = @hot_catch_app.network_interfaces

    @moment_format = format_moment(@step_metric)
    @parse_c3_date_format = format_c3_date(@step_metric)
    @show_datetime_format = format_show_datetime(@step_metric)


    @x = []
    @y = []

    @name_networks.each_with_index do |name, index|
      @networks = []
      networks = Network.where(hot_catch_app_id: @hot_catch_app.id, name: name).where(
        "get_time >= ? AND get_time <= ?",
        @begin_date.strftime(format_c3_date("second")),
        @end_date.strftime(format_c3_date("second"))
      ).order(:get_time)
      @y << ["#{name}: входящий трафик"]
      @y << ["#{name}: исходящий трафик"]
      @y << ["x#{index + 1}"]
      @x << [@y[-2][0], @y[-1][0]]
      @x << [@y[-3][0], @y[-1][0]]
      networks.group_by{|x| x.get_time.strftime(@format_date)}.each do |key, val|
        a = [0, 0]
        for network in val do
          a[0] += network.bytes_in.to_f
          a[1] += network.bytes_out.to_f
        end
        @y[-3] << a[0].round(2)
        @y[-2] << a[1].round(2)
        @y[-1] << DateTime.strptime(key, @format_date).strftime(@parse_c3_date_format)
      end
    end
    # ОТОБРАЖАЕМ @x и @y
    render :load_network_graph, :layout => false
  end


  def load_main_metric_graph
    @min_date = @hot_catch_app.system_metrics.order(:get_time).first
      .get_time.change(:offset => DateTime.now.zone).utc
    @max_date = @hot_catch_app.system_metrics.order(:get_time).last
      .get_time.change(:offset => DateTime.now.zone).utc
    # Настройки ============
    if params[:main_metric_form_step].blank?
      @step_metric = "hour"
      @show_time = true
    else
      @step_metric = params[:main_metric_form_step]
    end

    if params[:main_metric_graph_form_from].present?
      @begin_date = DateTime.strptime(params[:main_metric_graph_form_from],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @begin_date = @min_date
    end

    if params[:main_metric_graph_form_to].present?
      @end_date = DateTime.strptime(params[:main_metric_graph_form_to],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @end_date = @max_date
    end
    # ======================

    case @step_metric
    when "month"
      @format_date = ("%m.%Y")
    when "day"
      @format_date = ("%D")
    when "hour"
      @format_date = ("%D %H")
      @show_time = true
    else
      @format_date = ("%D %H:%M")
      @show_time = true
    end

    @moment_format = format_moment(@step_metric)
    @parse_c3_date_format = format_c3_date(@step_metric)
    @show_datetime_format = format_show_datetime(@step_metric)

    @all_metrics = @hot_catch_app.system_metrics.where(
      "get_time >= ? AND get_time <= ?",
      @begin_date.strftime(format_c3_date("second")),
      @end_date.strftime(format_c3_date("second"))
    ).order(:get_time)

    @x = ["x1"]
    @y = [["процессор"], ["использование памяти"],
      ["файл подкачки"], ["используемые дескрипторы"]]
    hash = @all_metrics.group_by{|x| x.get_time.strftime(@format_date)}
    hash.each do |key, val|
      a = [0, 0, 0, 0]
      for metric in val do
        a[0] += metric.cpu_average_minute.to_f
        a[1] += metric.memory_used.to_i  * (2 ** 10)
        a[2] += metric.swap_used * (2 ** 10)
        a[3] += metric.descriptors_used
      end
      a.map!{|x| x /= val.size}
      a[0] = (a[0] * 100).round(2)
      @x << DateTime.strptime(key, @format_date).strftime(@parse_c3_date_format)
      @y.each_with_index{|elem, index| elem << a[index]}
    end
    # ОТОБРАЖАЕМ @x и @y
    render :load_main_metric_graph, :layout => false
  end

  def show_server_graph
    gon.network_load_graph_path = load_network_graph_hot_catch_app_url(@hot_catch_app)
    gon.main_metric_load_graph_path = load_main_metric_graph_hot_catch_app_url(@hot_catch_app)
  end

  def show_server_statistic
    if @hot_catch_app.system_metrics.blank?
      flash[:danger] = "Статистика не найдена"
      redirect_to hot_catch_apps_path
    else
      gon.server_main_staticstic_path = get_ajax_table_main_metric_hot_catch_app_url(@hot_catch_app)
      gon.server_network_staticstic_path = get_ajax_table_network_metric_hot_catch_app_url(@hot_catch_app)
      @disks = @hot_catch_app.disks

      @network_names = @hot_catch_app.network_interfaces

      @rows_main_metric = 4
      @rows_network_metric = 5
    end
  end

  # Ajax подгрузка сетевых интерфейсов
  def get_ajax_table_network_metric
    @min_date = Network.where(hot_catch_app_id: @hot_catch_app.id)
      .order(:get_time).first.get_time.change(:offset => DateTime.now.zone).utc
    @max_date = Network.where(hot_catch_app_id: @hot_catch_app.id)
      .order(:get_time).last.get_time.change(:offset => DateTime.now.zone).utc
    # Настройки ============
    if params[:network_metric_form_step].blank?
      @step_metric = "hour"
      @show_time = true
    else
      @step_metric = params[:network_metric_form_step]
    end

    if params[:network_metric_table_form_from].present?
      @begin_date = DateTime.strptime(params[:network_metric_table_form_from],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @begin_date = @min_date
    end

    if params[:network_metric_table_form_to].present?
      @end_date = DateTime.strptime(params[:network_metric_table_form_to],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @end_date = @max_date
    end
    # ======================

    case @step_metric
    when "month"
      @format_date = ("%m.%Y")
    when "day"
      @format_date = ("%D")
    when "hour"
      @format_date = ("%D %H")
      @show_time = true
    else
      @format_date = ("%D %H:%M")
      @show_time = true
    end

    @name_networks = @hot_catch_app.network_interfaces
    @name_networks.map!{|name| [name]}

    @name_networks.each_with_index do |name, index|
      @networks = []
      networks = Network.where(hot_catch_app_id: @hot_catch_app.id, name: name[0]).where(
        "get_time >= ? AND get_time <= ?",
        @begin_date.strftime(format_c3_date("second")),
        @end_date.strftime(format_c3_date("second"))
      ).order(:get_time)
      networks.group_by{|x| x.get_time.strftime(@format_date)}.each do |key, val|
        a = [0, 0]
        for network in val do
          a[0] += network.bytes_in.to_f
          a[1] += network.bytes_out.to_f
        end
        a.unshift(DateTime.strptime(key, @format_date))
        @networks << a
      end
      @name_networks[index] << @networks.last(150)
    end

    render :get_ajax_table_network_metric, :layout => false
  end

  # Ajax подгрузка нагрузки на систему
  def get_ajax_table_main_metric
    @main_metric = @hot_catch_app.main_metric
    @min_time = @hot_catch_app.system_metrics.order(:get_time).first.get_time.change(:offset => DateTime.now.zone).utc
    @max_time = @hot_catch_app.system_metrics.order(:get_time).last.get_time.change(:offset => DateTime.now.zone).utc
    # Настройки ============
    if params[:main_metric_form_step].blank?
      @step_metric = "hour"
      @show_time = true
      @show_processor = true
      @show_memory = true
      @show_swap = true
      @show_descriptors = true
    else
      @show_processor = params[:main_metric_form_row_processor].present?
      @show_memory = params[:main_metric_form_row_memory].present?
      @show_swap = params[:main_metric_form_row_swap].present?
      @show_descriptors = params[:main_metric_form_row_descriptors].present?
      @step_metric = params[:main_metric_form_step]
    end

    if params[:main_metric_table_form_from].present?
      @begin_date = DateTime.strptime(params[:main_metric_table_form_from],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @begin_date = @min_time
    end

    if params[:main_metric_table_form_to].present?
      @end_date = DateTime.strptime(params[:main_metric_table_form_to],
        format_show_datetime("minute")).change(:offset => DateTime.now.zone).utc
    else
      @end_date = @max_time
    end
    # ======================

    case @step_metric
    when "month"
      @format_date = ("%m.%Y")
    when "day"
      @format_date = ("%D")
    when "hour"
      @format_date = ("%D %H")
      @show_time = true
    else
      @format_date = ("%D %H:%M")
      @show_time = true
    end


    @all_metrics = @hot_catch_app.system_metrics.where(
      "get_time >= ? AND get_time <= ?",
      @begin_date.strftime(format_c3_date("second")),
      @end_date.strftime(format_c3_date("second"))
    ).order(:get_time)

    @metrics = []
    hash = @all_metrics.group_by{|x| x.get_time.strftime(@format_date)}
    hash.each do |key, val|
      a = [0, 0, 0, 0]
      for metric in val do
        a[0] += metric.cpu_average_minute.to_f
        a[1] += metric.memory_used.to_i
        a[2] += metric.swap_used
        a[3] += metric.descriptors_used
      end
      a.map!{|x| x /= val.size}
      a.unshift(DateTime.strptime(key, @format_date))
      @metrics << a
    end
    @metrics = @metrics.last(100)

    render :get_ajax_table_main_metric, :layout => false
  end
  # ============================================================================

  def index
    @hot_catch_apps = HotCatchApp.paginate(:page => params[:page]).order('created_at DESC')
  end

  # ============================================================================
  def load_rails_graph
    if params[:rails_graph_form_step].blank?
      @step_metric = "hour"
      @show_time = true
    else
      @step_metric = params[:rails_graph_form_step]
    end

    # raise @step_metric

    case @step_metric
    when "month"
      @format_date = ("%m.%Y")
    when "day"
      @format_date = ("%D")
    when "hour"
      @format_date = ("%D %H")
      @show_time = true
    else
      @format_date = ("%D %H:%M")
      @show_time = true
    end

    @moment_format = format_moment(@step_metric)
    @parse_c3_date_format = format_c3_date(@step_metric)
    @show_datetime_format = format_show_datetime(@step_metric)

    @requests = UserRequest.non_success_count_date(@hot_catch_app, @format_date)
    a1, a2 = ["x"], ["Rails"]
    @requests.each{ |a| a1 << DateTime.strptime(a[0], @format_date)
      .strftime(@parse_c3_date_format); a2 << a[1] }
    @requests = [a1, a2]

    render :load_rails_graph, :layout => false
  end

  def show_rails_graph
    gon.load_rails_graph_path = load_rails_graph_hot_catch_app_url(@hot_catch_app)
  end

  def show
    @logs = @hot_catch_app.main_hot_catch_logs
    unless !params[:type].present? || (params[:type] == "all-filter")
      case params[:type]
      when "rails-server-filter"
        @logs = @logs.where(from_log: "Rails", status: "SERVER_ERROR")
      when "rails-client-filter"
        @logs = @logs.where(from_log: "Rails", status: "CLIENT_ERROR")
      end
    end
    @logs = @logs.paginate(:page => params[:page]).order('created_at DESC')
    respond_to do |format|
      @filter = params[:type]
      format.js {render layout: false}
      format.html
    end
  end
  # ============================================================================

  def new
    @hot_catch_app = HotCatchApp.new
  end

  def edit
  end

  def create
    @hot_catch_app = HotCatchApp.new(hot_catch_app_params)

    respond_to do |format|
      if @hot_catch_app.save
        format.html { redirect_to @hot_catch_app, notice: 'Hot catch app was successfully created.' }
        format.json { render :show, status: :created, location: @hot_catch_app }
      else
        format.html { render :new }
        format.json { render json: @hot_catch_app.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @hot_catch_app.update(hot_catch_app_params)
        format.html { redirect_to @hot_catch_app, notice: 'Hot catch app was successfully updated.' }
        format.json { render :show, status: :ok, location: @hot_catch_app }
      else
        format.html { render :edit }
        format.json { render json: @hot_catch_app.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @hot_catch_app.destroy
    respond_to do |format|
      format.html { redirect_to hot_catch_apps_url, notice: 'Hot catch app was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_hot_catch_app
      @hot_catch_app = HotCatchApp.find(params[:id])
    end

    def hot_catch_app_params
      params.require(:hot_catch_app).permit(:name)
    end
end
