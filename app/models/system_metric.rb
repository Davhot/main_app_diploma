class SystemMetric < ApplicationRecord
  belongs_to :hot_catch_app

  # validates :cpu_average_minute, presence: true
  # validates :memory_size, presence: true
  # validates :memory_used, presence: true
  # validates :swap_size, presence: true
  # validates :swap_used, presence: true
  # validates :discriptors_max, presence: true
  # validates :descriptors_used, presence: true

  def cpu_average_minute_in_percent
    "#{(cpu_average_minute * 100).round(2)}%"
  end
end
