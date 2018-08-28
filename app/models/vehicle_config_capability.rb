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
  acts_as_votable
  belongs_to :vehicle_config
  belongs_to :vehicle_capability
  belongs_to :confirmed_by, class_name: "User", optional: true

  # belongs_to :confirmed_by_user, :foreign_key => "confirmed_by"
  def humanize secs
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        if n > 0
        "#{n.to_i} #{name}"
        end
      end
    }.compact.reverse.join(' ')
  end

  amoeba do
    enable
  end

  def name
    if (vehicle_config && vehicle_capability)
      "#{vehicle_capability.name}"
    end
  end

  def timeout_friendly
    if !timeout.blank?
      humanize(timeout)
    end
  end

  def speed
    if !kph.blank?
      "#{mph} mph (#{kph} kph)"
    end
  end

  def mph
    if kph.present?
      (kph*0.621371).round
    end
  end

  def set_confirmed
    if confirmed_by.present?
      self.confirmed = true
    end
  end
end
