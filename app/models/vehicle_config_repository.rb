# == Schema Information
#
# Table name: vehicle_config_repositories
#
#  id                :bigint(8)        not null, primary key
#  vehicle_config_id :bigint(8)
#  repository_id     :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class VehicleConfigRepository < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :repository
  belongs_to :repository_branch
  
  def name
    "#{repository.name}"
  end
end
