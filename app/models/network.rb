class Network < ApplicationRecord
  belongs_to :hot_catch_app

  # Возвращает массив x и y для построения графика
  # Формат:
  # x: [[легенда оси y1, легенда оси x1], [легенда оси y2, легенда оси x1],
  # [легенда оси y3, легенда оси x2], [легенда оси y4, легенда оси x2], ...]
  # y: [[легенда оси y1, входящий трафик, исходящий, дата], [...], ...]
  def self.get_data_graph(app, step = "minute", from = nil, to = nil)
    x, y = [], []
    name_networks = self.pluck(:name).uniq

    name_networks.each_with_index do |name, index|
      networks = Network.where(hot_catch_app_id: app.id, name: name)
      networks = networks.where("get_time >= ?", I18n.l(from, format: :to_nginx)) if from
      networks = networks.where("get_time <= ?", I18n.l(to, format: :to_nginx)) if to
      networks = networks.order(:get_time)

      y << ["#{name}: входящий трафик"]
      y << ["#{name}: исходящий трафик"]
      y << ["x_network_#{index + 1}"]
      x << [y[-2][0], y[-1][0]]
      x << [y[-3][0], y[-1][0]]

      networks.group_by{|x| I18n.l(x.get_time, format: "datetime.#{step}".to_sym)}.each do |key, val|
        a = [0, 0]
        for network in val do
          a[0] += network.bytes_in.to_f
          a[1] += network.bytes_out.to_f
        end
        y[-3] << a[0].round(2)
        y[-2] << a[1].round(2)
        y[-1] << I18n.l(DateTime.strptime(key, I18n.t(step, scope: "time.formats.datetime")),
          format: "c3_date.#{step}".to_sym)
      end
    end
    [x, y]
  end

end
