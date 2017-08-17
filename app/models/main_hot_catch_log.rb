class MainHotCatchLog < ApplicationRecord
  STATUSES = %w( STATUS SUCCESS REDIRECTION CLIENT_ERROR SERVER_ERROR WARNING )
  FROM = %w( Rails Client Puma Nginx )

  validates :log_data, :name_app, presence: true
  validates :count_log, presence: true, numericality: {only_integer: true,
    greater_than: 0}
  validates :id_log_origin_app, numericality: {only_integer: true},
    uniqueness: {scope: [:name_app]}
  validates :from_log, presence: true, inclusion: {in: FROM}
  validates :status, inclusion: {in: STATUSES}


  def self.find_and_count_log_if_exist(id_log, name_app, count_log)
    l = MainHotCatchLog.where(id_log_origin_app: id_log, name_app: name_app).first
    l.update_attribute(:count_log, count_log) if l.present?
    l.present?
  end
end