# == Schema Information
#
# Table name: modifications
#
#  id           :bigint(8)        not null, primary key
#  name         :string
#  summary      :string
#  description  :text
#  instructions :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Modification < ApplicationRecord
  # include ModificationAdmin
  has_paper_trail
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :modification_hardware_types, dependent: :delete_all
  has_many :hardware_types, :through => :modification_hardware_types
  has_many :vehicle_config_modifications, dependent: :delete_all
  has_many :vehicle_configs, :through => :vehicle_config_modifications

  def vehicle_config_ids=(ids)
    self.vehicle_configs = Array(ids).reject(&:blank?).map do |id|
      (id =~ /^\d+$/) ? VehicleConfig.find(id) : VehicleConfig.new(name: id)
    end
  end
  
  def vehicle_config_names
    vehicle_configs.map(&:name).join(", ")
  end
end
