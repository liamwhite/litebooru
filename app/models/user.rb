class User
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Reportable
  include Sluggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time


  # Token authenticatable
  field :authentication_token, type: String

  # Non-devise fields
  field :name, type: String
  field :downcase_name, type: String
  set_slugged_field :name
  field :role, type: String, default: 'user'

  has_mongoid_attached_file :avatar, styles: {small: '20x20>', medium: '50x50>', large: '100x100>', huge: '200x200>'}, default_url: 'avatar-missing.svg'

  # Relations
  has_many :images
  has_many :hidden_images, class_name: 'Image'
  has_many :reports_made, inverse_of: :user, class_name: 'Report'
  has_many :managed_reports, inverse_of: :admin, class_name: 'Report'
  has_many :unread_notifications, inverse_of: nil, validate: false, class_name: 'Notification'

  # Indexes
  index name: 1
  index downcase_name: 1
  index unread_notifications: 1

  # Validations
  validates_uniqueness_of :downcase_name, message: 'Name is already taken.'
  validates_attachment :avatar, content_type: {content_type: %w|image/png image/jpeg image/gif|}, size: {in: 0..500.kilobytes}

  ALLOWED_DEVISE_PARAMETERS = [:avatar, :remove_avatar]

  # Callbacks
  before_validation do
    avatar.clear if @remove_avatar
    downcase_name = name.downcase if not downcase_name
  end


  def to_param
    slug
  end

  attr_reader :remove_avatar
  def remove_avatar=(value)
    @remove_avatar = value.to_i.zero?
  end
end
