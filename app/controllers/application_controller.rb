class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter do
    @start_time = Time.now
  end

  before_filter :configure_permitted_parameters_for_devise, if: :devise_controller?
  before_filter :unread_notifications

  def configure_permitted_parameters_for_devise
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update).concat(User::ALLOWED_DEVISE_PARAMETERS).uniq!
  end

  def render_404_if_not(cond, &block)
    if cond
      yield if block
    else
      render 'pages/render_404'
    end
  end

  def unread_notifications
    @unread_notifications = current_user.unread_notifications if current_user
  end
end
