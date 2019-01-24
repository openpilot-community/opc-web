
# == Schema Information
#
# Table name: users
#

#

class DiscordUserVehicle < ApplicationRecord
  belongs_to :discord_user, :foreign_key => :discord_user_id 

  def name
    "#{self.vehicle_year} #{self.vehicle_make} #{self.vehicle_model} #{self.vehicle_trim}"
  end
end