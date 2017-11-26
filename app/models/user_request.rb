class UserRequest < ApplicationRecord
  belongs_to :main_hot_catch_log, required: false

  validates :ip, :request_time, presence: true

  # Все запросы с ошибками по одному приложению
  def self.find_non_success(app)
    self.includes(:main_hot_catch_log, main_hot_catch_log: :hot_catch_app)
      .where(main_hot_catch_logs: {hot_catch_app_id: app.id})
      .where.not(main_hot_catch_logs: {status: 'SUCCESS'})
  end

  # получениe интегральных данных по невалидным запросам в приложении
  # [DATE, COUNT]
  def self.non_success_count_date(app, format_date)
    find_non_success(app).group_by{|x| x.request_time.strftime(format_date)}
      .map{|x| [x[0], x[1].size]}
  end
end
