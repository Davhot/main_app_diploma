class HotCatchAppsController < ApplicationController
  before_action :set_hot_catch_app, only: [:show, :edit, :update, :destroy]

  before_action -> {redirect_if_not_one_of_role_in ["admin"]}
  
  # GET /hot_catch_apps
  # GET /hot_catch_apps.json
  def index
    @hot_catch_apps = HotCatchApp.paginate(:page => params[:page])
  end

  # GET /hot_catch_apps/1
  # GET /hot_catch_apps/1.json
  def show
    @logs = @hot_catch_app.main_hot_catch_logs
    unless !params[:type].present? || (params[:type] == "all-filter")
      case params[:type]
      when "rails-server-filter"
        @logs = @logs.where(from_log: "Rails", status: "SERVER_ERROR")
      when "rails-client-filter"
        @logs = @logs.where(from_log: "Rails", status: "CLIENT_ERROR")
      end
    end
    @logs = @logs.paginate(:page => params[:page])
    respond_to do |format|
      @filter = params[:type]
      format.js {render layout: false}
      format.html
    end
  end

  # GET /hot_catch_apps/new
  def new
    @hot_catch_app = HotCatchApp.new
  end

  # GET /hot_catch_apps/1/edit
  def edit
  end

  # POST /hot_catch_apps
  # POST /hot_catch_apps.json
  def create
    @hot_catch_app = HotCatchApp.new(hot_catch_app_params)

    respond_to do |format|
      if @hot_catch_app.save
        format.html { redirect_to @hot_catch_app, notice: 'Hot catch app was successfully created.' }
        format.json { render :show, status: :created, location: @hot_catch_app }
      else
        format.html { render :new }
        format.json { render json: @hot_catch_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hot_catch_apps/1
  # PATCH/PUT /hot_catch_apps/1.json
  def update
    respond_to do |format|
      if @hot_catch_app.update(hot_catch_app_params)
        format.html { redirect_to @hot_catch_app, notice: 'Hot catch app was successfully updated.' }
        format.json { render :show, status: :ok, location: @hot_catch_app }
      else
        format.html { render :edit }
        format.json { render json: @hot_catch_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hot_catch_apps/1
  # DELETE /hot_catch_apps/1.json
  def destroy
    @hot_catch_app.destroy
    respond_to do |format|
      format.html { redirect_to hot_catch_apps_url, notice: 'Hot catch app was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hot_catch_app
      @hot_catch_app = HotCatchApp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hot_catch_app_params
      params.require(:hot_catch_app).permit(:name)
    end
end
