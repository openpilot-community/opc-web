# == Schema Information
#
# Table name: vehicle_model_options
#
#  id                             :bigint(8)        not null, primary key
#  vehicle_year                   :integer
#  vehicle_make_id                :bigint(8)
#  vehicle_model_id               :bigint(8)
#  vehicle_option_id              :bigint(8)
#  vehicle_option_availability_id :bigint(8)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

class VehicleModelOption < ApplicationRecord
  belongs_to :vehicle_make
  belongs_to :vehicle_model
  belongs_to :vehicle_option
  belongs_to :vehicle_option_availability

  def name
    "#{vehicle_option.name}: #{vehicle_option_availability.name}"
  end
end