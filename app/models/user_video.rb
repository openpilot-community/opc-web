# == Schema Information
#
# Table name: user_videos
#
#  id                :bigint(8)        not null, primary key
#  user_id :bigint(8)
#  video_id          :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class UserVideo < ApplicationRecord
  belongs_to :user
  belongs_to :video
  accepts_nested_attributes_for :video
  
  def name
    video.title
  end

  def thumbnail_url
    video.thumbnail_url
  end

  def author
    video.author
  end
end
