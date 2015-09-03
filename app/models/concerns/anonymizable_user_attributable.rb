# TODO: can we combine this with UserAttributable?
module AnonymizableUserAttributable
  extend ActiveSupport::Concern
  include UserAttributable

  included do
    field :anonymous, type: Boolean, default: false
  end

  def author
    self.user if (self.user and not self.anonymous)
  end
end
