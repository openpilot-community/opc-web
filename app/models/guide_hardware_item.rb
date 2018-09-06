class GuideHardwareItem < ApplicationRecord
  belongs_to :guide
  belongs_to :hardware_item
end
