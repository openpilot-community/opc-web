# == Schema Information
#
# Table name: vehicle_config_types
#
#  id               :bigint(8)        not null, primary key
#  name             :string
#  description      :text
#  difficulty_level :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class VehicleConfigType < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :vehicle_configs
end
