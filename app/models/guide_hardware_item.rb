class GuideHardwareItem < ApplicationRecord
  belongs_to :guide
  belongs_to :hardware_item
  accepts_nested_attributes_for :guide
  def name
    "#{hardware_item.name} / #{guide.title}"
  end
end
