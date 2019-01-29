
# == Schema Information
#
# Table name: users
#

#

class DiscordUser < ApplicationRecord
  belongs_to :user
  has_many :discord_user_vehicles
  has_many :discord_messages
end