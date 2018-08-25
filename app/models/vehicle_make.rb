# == Schema Information
#
# Table name: vehicle_makes
#
#  id            :bigint(8)        not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  slack_channel :string
#  slug          :string
#

class VehicleMake < ApplicationRecord
  default_scope { order(:name) }
  paginates_per 200
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_paper_trail
  
  has_many :vehicle_make_package
  has_many :vehicle_models
  has_many :vehicle_configs
  has_many :vehicle_trims
  scope :with_configs, -> { VehicleMake.includes(:vehicle_models).joins(:vehicle_configs).where("vehicle_configs.id IS NOT NULL").order("vehicle_makes.name").uniq }
  
  def active_count
    vehicle_models.where(status: 1).count()
  end

  def inactive_count
    vehicle_models.where(status: 0).count()
  end
  
  def vehicle_models_with_configs
    if vehicle_models
      vehicle_models.order("name").select do |model|
        model.has_configs?
      end
      # left_outer_joins(:vehicle_configs).where.not(vehicle_configs: {id: nil})
    end
  end
  
  # def name_for_slug
  #   "#{id} #{name}"
  # end
  # def to_param
  #   slug
  # end
  def has_configs
    !vehicle_configs.blank?
  end
end
