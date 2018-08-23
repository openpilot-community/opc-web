# == Schema Information
#
# Table name: repositories
#
#  id               :bigint(8)        not null, primary key
#  name             :string
#  full_name        :string
#  owner_login      :string
#  owner_avatar_url :string
#  owner_url        :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Repository < ApplicationRecord
  has_many :vehicle_config_repositories
  has_many :vehicle_configs, :through => :vehicle_config_repositories
  
  def name
    full_name
  end
end
