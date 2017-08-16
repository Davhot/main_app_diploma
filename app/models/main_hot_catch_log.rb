class MainHotCatchLog < ApplicationRecord
  STATUSES = %w( STATUS SUCCESS REDIRECTION CLIENT_ERROR SERVER_ERROR WARNING )
  FROM = %w( Rails Client Puma Nginx )

  validates :log_data, :name_app, presence: true
  validates :count_log, presence: true, numericality: {only_integer: true,
    greater_than: 1}
  validates :id_log_origin_app, numericality: {only_integer: true}
  validates :from_log, presence: true, inclusion: {in: FROM}
  validates :status, inclusion: {in: STATUSES}
end
