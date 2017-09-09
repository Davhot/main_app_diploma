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

  private

  def set_app
    self.hot_catch_app = HotCatchApp.find_or_create_by(name: name_app)
  end

  # Проверка лога на уникальность
  def process_log_data
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
