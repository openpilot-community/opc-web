class VehicleTrim < ApplicationRecord
  has_paper_trail
  default_scope{ order(:year,:sort_order) }
  belongs_to :vehicle_model
  # has_many :vehicle_config_vehicle_trims
  # has_many :vehicle_configs, :through => :vehicle_config_vehicle_trims
  has_many :vehicle_trim_styles

  def name_for_list
    "#{vehicle_model.vehicle_make.name} #{vehicle_model.name} #{name}, #{year}"
  end

  def image
    vehicle_configs.first.root.image if vehicle_configs.present? && vehicle_configs.first.root.image.present?
  end

  def make_name
    vehicle_model.vehicle_make.name
  end

  def vehicle_configs
    VehicleConfig.where(%(
      (
        vehicle_configs.vehicle_model_id = :vehicle_model AND 
        vehicle_configs.year = :year
      ) OR (
        vehicle_configs.vehicle_model_id = :vehicle_model AND 
        (:year BETWEEN vehicle_configs.year AND vehicle_configs.year_end)
      )
    ),{
      vehicle_make: vehicle_model.vehicle_make.id,
      vehicle_model: vehicle_model.id,
      year: year
    })
  end

  def has_driver_assist?
    !driver_assist.blank?
  end

  def has_vehicle_trim_styles?
    !vehicle_trim_styles.blank?
  end

  def driver_assisted_style_names
    if has_vehicle_trim_styles?
      driver_assist.map(&:name_for_list).join(", ")
    end
  end

  def is_adas_option?
    driver_assist.select { |da| da.driver_assist_inclusion == "option" }
  end

  def driver_assist
    vehicle_trim_styles.joins(:vehicle_trim_style_specs).where("vehicle_trim_style_specs.name LIKE '%Adaptive Cruise%' OR vehicle_trim_style_specs.name LIKE '% pacing %'").group(:id,:name)
  end
end
