class SystemMetric < ApplicationRecord
  has_many :networks
  belongs_to :hot_catch_app

  # validates :cpu_average_minute, presence: true
  # validates :memory_size, presence: true
  # validates :memory_used, presence: true
  # validates :swap_size, presence: true
  # validates :swap_used, presence: true
  # validates :discriptors_max, presence: true
  # validates :descriptors_used, presence: true
end
