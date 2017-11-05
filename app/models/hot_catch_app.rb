class HotCatchApp < ApplicationRecord
  has_many :main_hot_catch_logs
  has_many :disks
  has_many :system_metrics

  self.per_page = 10 # пагинация

  validates :name, presence: true, uniqueness: true

  def count_errors
    sum = 0
    self.main_hot_catch_logs
      .where('status in (?)', %w(CLIENT_ERROR SERVER_ERROR WARNING UNKNOWN))
      .map{|x| sum += x.count_log}
    sum
  end
end
