# == Schema Information
#
# Table name: vehicle_config_hardwares
#
#  id                :bigint(8)        not null, primary key
#  vehicle_config_id :bigint(8)
#  hardware_item_id  :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class VehicleConfigHardwareItem < ApplicationRecord
  # self.table_name = "vehicle_config_hardwares"
  belongs_to :vehicle_config
  belongs_to :hardware_item
  accepts_nested_attributes_for :hardware_item
  def name
    hardware_item.name
  end
end
