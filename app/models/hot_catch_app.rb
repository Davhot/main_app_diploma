class HotCatchApp < ApplicationRecord
  has_many :main_hot_catch_logs

  validates :name, presence: true, uniqueness: true

  def count_errors
    sum = 0
    self.main_hot_catch_logs.map{|x| sum += x.count_log}
    sum
  end
end
