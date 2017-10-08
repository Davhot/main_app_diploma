class HotCatchAppsController < ApplicationController
  before_action :set_hot_catch_app, only: [:show, :edit, :update, :destroy,
    :show_nginx_statistic, :show_server_statistic]

  before_action -> {redirect_if_not_one_of_role_in ["admin"]}

  def show_nginx_statistic
    o_file = "log/apps/#{@hot_catch_app.name.downcase}-report.html"
    if File.exist? o_file
      render file: o_file, layout: true
    else
      flash[:danger] = "Статистика не найдена"
      redirect_to hot_catch_app_path(@hot_catch_app)
    end
  end

  def show_server_statistic
    o_file = "log/apps/#{@hot_catch_app.name.downcase}-system.txt"
    unless File.exist? o_file
      flash[:danger] = "Статистика не найдена"
      redirect_to hot_catch_app_path(@hot_catch_app)
    else
      @server_logs = ""
      File.open(o_file, 'r'){|file| @server_logs = file.read}
    end
  end

  def index
    @hot_catch_apps = HotCatchApp.paginate(:page => params[:page]).order('created_at DESC')
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
