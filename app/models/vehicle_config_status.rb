# == Schema Information
#
# Table name: vehicle_config_statuses
#
#  id          :bigint(8)        not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class VehicleConfigStatus < ApplicationRecord
  has_many :vehicle_configs

end
