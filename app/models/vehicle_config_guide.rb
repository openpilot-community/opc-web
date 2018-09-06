class VehicleConfigGuide < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :guide
  belongs_to :vehicle_config_type, optional: true
  accepts_nested_attributes_for :guide
  def name
    self.guide.title
  end
end
