class Micropost < ActiveRecord::Base
  #generated automatically by the migration
  #each micropost belongs to one user
  belongs_to :user
  #order post by creation in descending order, ie. newest first
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size
  
  private
  
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end
end
