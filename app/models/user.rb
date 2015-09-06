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
end
