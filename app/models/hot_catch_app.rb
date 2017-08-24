class HotCatchApp < ApplicationRecord
  has_many :main_hot_catch_logs

  validates :name, presence: true
end
