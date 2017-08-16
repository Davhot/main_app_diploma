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
    respond_to do |format|
      format.json {head :ok}
    end
    # @main_hot_catch_log = MainHotCatchLog.new(main_hot_catch_log_params)
    #
    # respond_to do |format|
    #   if @main_hot_catch_log.save
    #     format.html { redirect_to @main_hot_catch_log, notice: 'Main hot catch log was successfully created.' }
    #     format.json { render :show, status: :created, location: @main_hot_catch_log }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @main_hot_catch_log.errors, status: :unprocessable_entity }
    #   end
    # end
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
      params.require(:main_hot_catch_log).permit(:log_data, :count_log, :id_log_origin_app, :name_app, :from_log)
    end
end
