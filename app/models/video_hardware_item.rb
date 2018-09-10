# == Schema Information
#
# Table name: video_hardwares
#
#  id               :bigint(8)        not null, primary key
#  video_id         :bigint(8)
#  hardware_item_id :bigint(8)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class VideoHardwareItem < ApplicationRecord
  belongs_to :video
  belongs_to :hardware_item
  accepts_nested_attributes_for :video

  def name
    "#{video.title}"
  end
end
