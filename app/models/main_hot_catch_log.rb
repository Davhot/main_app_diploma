class MainHotCatchLog < ApplicationRecord
  belongs_to :hot_catch_app
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
    o_file = "log/apps/#{hot_catch_app.name.downcase}-system.txt"
    file = File.open(o_file, 'a')

    file.puts "#{logs}\n\n"

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
      o_file = "log/apps/#{hot_catch_app.name.downcase}-report.html"
      File.open(i_file, 'a'){|file| file.write log_data}
      `goaccess -f #{i_file} -o html > #{o_file}`
      true
    else
      str = self.log_data
      parser = RailsLogParser.new
      self.status = parser.get_status(self.log_data, self.status)
      str2 = parser.strip_str(str)
      MainHotCatchLog.where(status: status, hot_catch_app_id: hot_catch_app.id).each do |cur_log|
        if parser.strip_str(cur_log.log_data) == str2
          cur_log.update_attribute(:count_log, cur_log.count_log + 1)
          return true
        end
      end
      self.log_data = parser.strip_str(str)
      self.save
    end
  end
end
