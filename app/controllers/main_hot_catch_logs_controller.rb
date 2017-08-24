class MainHotCatchLogsController < ApplicationController
  before_action :set_main_hot_catch_log, only: [:show, :edit, :update, :destroy]

  skip_before_action :verify_authenticity_token, only: [:create]
  # GET /main_hot_catch_logs
  # GET /main_hot_catch_logs.json
  def index
    @main_hot_catch_logs = MainHotCatchLog.all
  end

  # GET /main_hot_catch_logs/1
  # GET /main_hot_catch_logs/1.json
  def show
  end

  # GET /main_hot_catch_logs/new
  def new
    @main_hot_catch_log = MainHotCatchLog.new
  end

  # GET /main_hot_catch_logs/1/edit
  def edit
  end

  # POST /main_hot_catch_logs
  # POST /main_hot_catch_logs.json
  def create
    p = params[:main_hot_catch_log]
    p1, p2, p3 = p[:id_log_origin_app], p[:name_app], p[:count_log]
    respond_to do |format|
      is_found_log = MainHotCatchLog.find_and_count_log_if_exist(p1, p2, p3)
      @main_hot_catch_log = MainHotCatchLog.new(main_hot_catch_log_params) unless is_found_log
      if is_found_log || @main_hot_catch_log.save
        unless (a = HotCatchApp.where(name: @main_hot_catch_log.name_app).first).present?
          a = HotCatchApp.create(name: @main_hot_catch_log.name_app)
        end
        a.main_hot_catch_logs << @main_hot_catch_log

        format.json { head :ok }
      else
        format.json { render json: @main_hot_catch_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /main_hot_catch_logs/1
  # PATCH/PUT /main_hot_catch_logs/1.json
  def update
    respond_to do |format|
      if @main_hot_catch_log.update(main_hot_catch_log_params)
        format.html { redirect_to @main_hot_catch_log, notice: 'Main hot catch log was successfully updated.' }
        format.json { render :show, status: :ok, location: @main_hot_catch_log }
      else
        format.html { render :edit }
        format.json { render json: @main_hot_catch_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /main_hot_catch_logs/1
  # DELETE /main_hot_catch_logs/1.json
  def destroy
    @main_hot_catch_log.destroy
    respond_to do |format|
      format.html { redirect_to main_hot_catch_logs_url, notice: 'Main hot catch log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_main_hot_catch_log
      @main_hot_catch_log = MainHotCatchLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def main_hot_catch_log_params
      params.require(:main_hot_catch_log).permit(:log_data, :count_log,
        :id_log_origin_app, :name_app, :from_log, :status)
    end
end
