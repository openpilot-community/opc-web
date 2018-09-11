class VehicleConfigImage < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :image

  def name
    "#{vehicle_config.name} / #{image.name}"
  end

  def as_json(options={})
    {
      created_at: created_at,
      guide_id: guide_id,
      id: id,
      name: image.name,
      image_id: image_id,
      updated_at: updated_at,
      url: image.attachment_url
    }
  end
end
