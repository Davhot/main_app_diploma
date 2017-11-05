class MainHotCatchLog < ApplicationRecord
  belongs_to :hot_catch_app
  has_many :user_requests
  attr_accessor :name_app

  self.per_page = 20 # пагинация

  STATUSES = %w( STATUS SUCCESS REDIRECTION CLIENT_ERROR SERVER_ERROR WARNING UNKNOWN )
  FROM = %w( Rails Client Puma Nginx )

  validates :log_data, presence: true, uniqueness: true
  validates :count_log, numericality: {only_integer: true, greater_than: 0}
  validates :from_log, presence: true, inclusion: {in: FROM}
  validates :status, presence: true, inclusion: {in: STATUSES}

  def set_data_and_save
    set_app
    process_log_data
  end

  def set_app_and_process_system_logs(logs)
    set_app
    process_system_logs(logs)
  end

  private

  def set_app
    self.hot_catch_app = HotCatchApp.find_or_create_by(name: name_app)
  end

  def process_system_logs(logs)
    metric = SystemMetric.create(cpu_average_minute: logs["cpu"]["last_minute"],
      memory_size: logs["memory"]["size"], memory_used: logs["memory"]["used"],
      swap_size: logs["memory"]["swap_size"], swap_used: logs["memory"]["swap_used"],
      discriptors_max: logs["descriptors"]["max"],
      descriptors_used: logs["descriptors"]["current"],
      get_time: logs["time"],
      hot_catch_app_id: hot_catch_app.id)

    # Обновляем/создаём диски
    disks = []
    logs["disk"].each do |k, v|
      disks << Disk.find_or_create_by(name: k)
      if disks[-1].present?
        disks[-1].update_attributes({
          filesystem: v["filesystem"],
          size: v["size"],
          used: v["used"],
          mounted_on: v["mounted_on\n"].strip,
          hot_catch_app_id: hot_catch_app.id})
      end
    end
    # Удаляем ненужные
    for disk_name in hot_catch_app.disks.pluck(:name) - disks.map{|d| d.name} do
      Disk.find_by(name: disk_name, hot_catch_app_id: hot_catch_app.id).destroy
    end

    logs["network"].each do |k, v|
      network = Network.create(name: k,
        bytes_in: v["bytes_in"],
        bytes_out: v["bytes_out"],
        packets_in: v["packets_in"],
        packets_out: v["packets_out"],
        system_metric_id: metric.id)
    end

    o_file = "log/apps/#{hot_catch_app.name.downcase}-system.txt"
    file = File.open(o_file, 'w')

    file.puts
    File.open("log/apps/system.json", 'w'){|file| file.puts logs}

    logs.each do |key, val|
      if key != "time"
        file.puts "#{key}:"
        val.each do |part_key, part_val|
          if %w(network disk).include?(key)
            file.puts "  #{part_key}:"
            part_val.each do |part_key2, part_val2|
              file.puts "    #{part_key2.to_s.strip} #{part_val2.to_s.strip}"
            end
          else
            file.puts "  #{part_key} #{part_val}"
          end
        end
      else
        file.puts "#{key} #{val}"
      end
    end
    file.puts ?= * 70 + "\n"
    file.close

    true
  end

  # Проверка лога на уникальность
  def process_log_data
    if from_log == "Nginx"
      i_file = "log/apps/#{hot_catch_app.name.downcase}-nginx.access.log"
      o_file = "log/apps/#{hot_catch_app.name.downcase}-report.json"
      File.open(i_file, 'a'){|file| file.write log_data}
      `goaccess -f #{i_file} -o json > #{o_file}`
      true
    else
      str = self.log_data
      parser = RailsLogParser.new
      # Сводка по времени и ip запросов
      ip, date = parser.get_ip_and_date(str)
      req = UserRequest.create(ip: ip, request_time: date)
      # Берём статус запроса
      self.status = parser.get_status(self.log_data, self.status)
      str2 = parser.strip_str(str)
      # Если есть лог, то count_log += 1
      MainHotCatchLog.where(status: status,
      hot_catch_app_id: hot_catch_app.id).each do |cur_log|
        if parser.strip_str(cur_log.log_data) == str2
          cur_log.user_requests << req if req.present?
          cur_log.update_attribute(:count_log, cur_log.count_log + 1)
          return true
        end
      end
      self.log_data = parser.strip_str(str)
      self.user_requests << req if req.present?
      self.save
    end
  end
end
