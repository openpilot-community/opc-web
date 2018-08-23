# == Schema Information
#
# Table name: vehicle_options
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  alternate_name    :string
#  what_it_does      :text
#  what_it_doesnt_do :text
#  reference_url     :string
#

class VehicleOption < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  # belongs_to :vehicle_option_availability
end
