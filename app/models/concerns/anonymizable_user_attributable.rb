# TODO: can we combine this with UserAttributable?
module AnonymizableUserAttributable
  extend ActiveSupport::Concern

  included do
    field :ip, type: String, default: ''
    field :user_agent, type: String, default: ''
    field :anonymous, type: Boolean, default: false
  end

  def author
    self.user if (self.user and not self.anonymous)
  end
end
