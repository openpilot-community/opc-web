class VehicleConfigModification < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :modification
  
  def name
    "#{modification.name}"
  end

  def hardware_item_names
    modification.modification_hardware_types.map(&:hardware_item_names).join(", ")
  end
end
