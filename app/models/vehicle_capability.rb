# == Schema Information
#
# Table name: vehicle_capabilities
#
#  id          :bigint(8)        not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class VehicleCapability < ApplicationRecord
  include CapabilityMethods
  extend FriendlyId
  paginates_per 400
  friendly_id :name, use: :slugged
  has_many :vehicle_config_capabilities
  has_many :vehicle_config, :through => :vehicle_config_capabilities

  def should_generate_new_friendly_id?
    name_changed?
  end

  def timeout
    if default_timeout.present?
      default_timeout
    else
      0
    end
  end

  def kph
    if default_kph.present?
      default_kph
    else
      0
    end
  end

  def state
    if default_state.present?
      default_state
    else
      0
    end
  end
  
  # def set_defaults
  #   if self.value_type.blank?
  #     self.value_type = 'toggle' # feeds a boolean field
  #   end
  # end
  
end
