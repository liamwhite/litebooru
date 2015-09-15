module UserAttributable
  extend ActiveSupport::Concern

  def author
    self.user
  end

  def capture!(user, request)
    self.ip = request.remote_ip
    self.user_agent = request.env['HTTP_USER_AGENT']
    self.user = user
  end
end
