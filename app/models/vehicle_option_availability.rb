# == Schema Information
#
# Table name: vehicle_option_availabilities
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VehicleOptionAvailability < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
end
