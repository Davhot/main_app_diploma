class MainHotCatchLogsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  skip_before_action :require_login
  skip_before_action :check_app_auth

  # POST /main_hot_catch_logs
  # POST /main_hot_catch_logs.json
  def create
    p = params[:main_hot_catch_log]
    p1, p2, p3 = p[:id_log_origin_app], p[:name_app], p[:count_log]
    respond_to do |format|
      is_found_log = MainHotCatchLog.find_and_count_log_if_exist(p1, p2, p3)
      @main_hot_catch_log = MainHotCatchLog.new(main_hot_catch_log_params) unless is_found_log
      if is_found_log || @main_hot_catch_log.save
        unless is_found_log
          unless (a = HotCatchApp.where(name: @main_hot_catch_log.name_app).first).present?
            a = HotCatchApp.create(name: @main_hot_catch_log.name_app)
          end
          a.main_hot_catch_logs << @main_hot_catch_log
        end

        format.json { head :ok }
      else
        format.json { render json: @main_hot_catch_log.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def main_hot_catch_log_params
      params.require(:main_hot_catch_log).permit(:log_data, :count_log,
        :id_log_origin_app, :name_app, :from_log, :status)
    end
end
