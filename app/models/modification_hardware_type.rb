class ModificationHardwareType < ApplicationRecord
  # include ModificationHardwareTypeAdmin
  belongs_to :modification
  belongs_to :hardware_type
  has_many :modification_hardware_type_hardware_items, dependent: :delete_all
  has_many :hardware_items, :through => :modification_hardware_type_hardware_items
  
  def name
    if (modification && hardware_type)
      "#{hardware_type.name}"
    end
  end

  def hardware_item_names
    if !hardware_items.blank?
      hardware_items.map(&:name).join(", ")
    else
      hardware_type.hardware_items.map(&:name).join(", ")
    end
  end
end
