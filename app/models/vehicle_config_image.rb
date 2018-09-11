class VehicleConfigImage < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :image

  def name
    "#{vehicle_config.name} / #{image.name}"
  end
end
