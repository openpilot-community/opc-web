class VehicleTrimStyle < ApplicationRecord
  has_paper_trail
  acts_as_votable
  # default_scope{ order(:name) }
  belongs_to :vehicle_trim
  has_many :vehicle_trim_style_specs
  
  def name_for_list
    "#{name.gsub("#{vehicle_trim.name} ",'')}"
  end

  def year
    vehicle_trim.year
  end

  def trim_name
    vehicle_trim.name
  end

  def has_specs?
    !vehicle_trim_style_specs.blank?
  end

  def price
    inventory_prices.gsub('Starting at','')
  end

  def driver_assist_inclusion
    if !driver_assist_specs.blank?
      driver_assist_specs.first.inclusion
    end
  end
  
  def driver_assist_specs
    vehicle_trim_style_specs.where("name LIKE '%Adaptive Cruise%' OR name LIKE '% pacing %'")
  end
  # def make_name
  #   vehicle_model.vehicle_make.name
  # end
end
