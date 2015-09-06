module UserAttributable
  extend ActiveSupport::Concern

  def author
    self.user
  end
end
