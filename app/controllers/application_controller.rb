class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login
  before_action :check_app_auth

  private
  ## Выбор текущей роли и проверка прав доступа для неё у данного пользователя
  def check_app_auth()
    if current_user.nil?
      redirect_to login_path, notice: flash[:notice]
    end
  end

  def not_authenticated
    flash[:warning] = 'You have to authenticate to access this page.'
    redirect_to login_path
  end

end
