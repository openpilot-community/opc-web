
# == Schema Information
#
# Table name: users
#

#
class MakeNameValidator < ActiveModel::Validator
  def validate(record)
    vehicle_make = VehicleMake.find_by(:name => record.vehicle_make)

    if !vehicle_make
      record.errors[:vehicle_make] << "The make you specified is not found."
    end
  end
end
class DiscordUserVehicle < ApplicationRecord
  belongs_to :discord_user, :foreign_key => :discord_user_id
  belongs_to :vehicle_config, optional: true
  validates_presence_of :vehicle_year, :vehicle_make, :vehicle_model
  validates_numericality_of :vehicle_year
  validates_with MakeNameValidator, on: :create
  def name
    "#{self.vehicle_year} #{self.vehicle_make} #{self.vehicle_model} #{self.vehicle_trim}"
  end
end