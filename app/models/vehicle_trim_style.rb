class VehicleTrimStyle < ApplicationRecord
  has_paper_trail
  # default_scope{ order(:name) }
  belongs_to :vehicle_trim
  has_many :vehicle_trim_style_specs
  
  def name_for_list
    "#{name.gsub("#{vehicle_trim.name} ",'')}, #{driver_assist_inclusion}"
  end

  def has_specs?
    !vehicle_trim_style_specs.blank?
  end
  
  def driver_assist_inclusion
    driver_assist_specs.first.inclusion
  end
  def driver_assist_specs
    vehicle_trim_style_specs.where("name LIKE '%Adaptive Cruise%' OR name LIKE '% pacing %'")
  end
  # def make_name
  #   vehicle_model.vehicle_make.name
  # end
end
