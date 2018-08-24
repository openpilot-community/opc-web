# == Schema Information
#
# Table name: vehicle_config_pull_requests
#
#  id                :bigint(8)        not null, primary key
#  vehicle_config_id :bigint(8)
#  pull_request_id   :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class VehicleConfigPullRequest < ApplicationRecord
  belongs_to :vehicle_config
  belongs_to :pull_request

  def name
    pull_request.name
  end
end
