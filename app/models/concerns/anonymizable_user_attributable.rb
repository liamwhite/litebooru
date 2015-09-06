module AnonymizableUserAttributable
  extend ActiveSupport::Concern
  include UserAttributable

  def author
    self.user if (self.user and not self.anonymous)
  end
end
