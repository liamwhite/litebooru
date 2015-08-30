module UserAttributable
  extend ActiveSupport::Concern

  included do
    # Fields
    field :ip, type: String
    field :user_agent, type: String, default: ''

    # N.B. assume belongs_to :user is already defined on model.
    # Otherwise we run into trouble with model-specific relations.
  end

  def author
    self.user
  end
end
