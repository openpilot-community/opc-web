class ModificationHardwareTypeHardwareItem < ApplicationRecord
  belongs_to :modification_hardware_type
  belongs_to :hardware_item

  def name
    "#{modification_hardware_type.name} #{hardware_item.name}"
  end
end
