class HardwareItemImage < ApplicationRecord
  belongs_to :hardware_item
  belongs_to :image
  accepts_nested_attributes_for :image
  def name
    "#{hardware_item.name} / #{image.name}"
  end

  def as_json(options={})
    {
      created_at: created_at,
      hardware_item_id: hardware_item_id,
      id: id,
      name: image.name,
      image_id: image_id,
      updated_at: updated_at,
      url: image.attachment_url
    }
  end
end
