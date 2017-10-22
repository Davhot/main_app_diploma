class UserRequest < ApplicationRecord
  belongs_to :main_hot_catch_log, required: false

  validates :ip, :request_time, presence: true
end
