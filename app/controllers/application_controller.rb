class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter do
    @start_time = Time.now
  end

  def render_404_if_not(cond, &block)
    if cond
      yield
    else
      render 'pages/render_404'
    end
  end
end
