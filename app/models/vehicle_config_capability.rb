# == Schema Information
#
# Table name: vehicle_config_capabilities
#
#  id                     :bigint(8)        not null, primary key
#  vehicle_config_id      :bigint(8)
#  vehicle_capability_id  :bigint(8)
#  kph                    :integer
#  timeout                :integer
#  confirmed              :boolean
#  confirmed_by           :integer
#  notes                  :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  vehicle_config_type_id :bigint(8)
#

class VehicleConfigCapability < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include CapabilityMethods
  enum state: {not_applicable: 0, is_included: 1, is_excluded: 2}
  acts_as_votable
  belongs_to :vehicle_config
  belongs_to :vehicle_capability
  belongs_to :vehicle_config_type
  belongs_to :confirmed_by, class_name: "User", optional: true
  before_save :set_capability_usage
  # belongs_to :confirmed_by_user, :foreign_key => "confirmed_by"

  def set_capability_usage
    usage_count = VehicleConfigCapability.where(vehicle_capability: self.vehicle_capability).count()
    VehicleCapability.find(vehicle_capability.id).update_attributes(vehicle_config_count: usage_count)
  end

  def value
    case vehicle_capability.value_type
    when "timeout"
      timeout_friendly
    when "speed"
      speed
    end
  end
  
  def name
    if (vehicle_config && vehicle_capability)
      "#{vehicle_capability.name}"
    end
  end

  def set_confirmed
    if confirmed_by.present?
      self.confirmed = true
    end
  end
  def as_json(options={})
    {
      id: self.id,
      state: self.current_numeric_state,
      vehicle_config_id: self.vehicle_config_id,
      vehicle_capability_id: self.vehicle_capability_id,
      vehicle_config_type_id: self.vehicle_config_type_id,
      value_type: self.vehicle_capability.value_type,
      kph: self.kph,
      timeout: self.timeout,
      confirmed: self.confirmed,
      friendly_text: self.value,
      notes: self.notes,
      created_at: self.created_at,
      updated_at: self.updated_at,
      confirmed_by_id: self.confirmed_by_id,
      string_value: self.string_value
    }
  end
end
