# == Schema Information
#
# Table name: vehicle_config_required_options
#
#  id                :bigint(8)        not null, primary key
#  vehicle_config_id :bigint(8)
#  vehicle_option_id :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class VehicleConfigRequiredOption < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :vehicle_option
end
