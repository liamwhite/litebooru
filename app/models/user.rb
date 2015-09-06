class User < ActiveRecord::Base
  include Reportable
  include Sluggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Relations
  has_many :images
  has_many :hidden_images, class_name: 'Image'
  has_many :reports_made, inverse_of: :user, class_name: 'Report'
  has_many :managed_reports, inverse_of: :admin, class_name: 'Report'

  has_attached_file :avatar, styles: {small: '20x20>', medium: '50x50>', large: '100x100>', huge: '200x200>'}, default_url: 'avatar-missing.svg'

  # Validations
  validates_uniqueness_of :downcase_name, message: 'Name is already taken.'
  validates_attachment :avatar, content_type: {content_type: %w|image/png image/jpeg image/gif|}, size: {in: 0..500.kilobytes}

  # Callbacks
  before_validation do
    avatar.clear if @remove_avatar
    downcase_name = name.downcase if not downcase_name
  end

  attr_reader :remove_avatar
  def remove_avatar=(value)
    @remove_avatar = value.to_i.zero?
  end

  def to_param
    slug
  end
end
