class UserVehicle < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle_config
  belongs_to :vehicle_trim, optional: true
  belongs_to :vehicle_trim_style, optional: true
  has_one_attached :image
  after_save :update_counts
  after_destroy :update_counts
  after_save :set_image_scraper

  def name
    new_name = []

    if vehicle_trim.present?
      new_name << vehicle_trim.year
    end
    if vehicle_config.present? && vehicle_config.vehicle_make.present?
      new_name << vehicle_config.vehicle_make.name
    end

    if vehicle_trim_style.present?
      new_name << vehicle_trim_style.name
    end

    new_name.join(' ')
  end
  def update_counts
    if vehicle_config_id.present?
      VehicleConfig.find(vehicle_config_id).update_attributes(user_count: UserVehicle.where(vehicle_config_id: vehicle_config_id).count)
    end
    if vehicle_trim_id.present?
      VehicleTrim.find(vehicle_trim_id).update_attributes(user_count: UserVehicle.where(vehicle_trim_id: vehicle_trim_id).count)
    end
    if vehicle_trim_style_id.present?
      VehicleTrimStyle.find(vehicle_trim_style_id).update_attributes(user_count: UserVehicle.where(vehicle_trim_style_id: vehicle_trim_style_id).count)
    end
  end
  def set_image_scraper
    if saved_change_to_source_image_url?
      DownloadImageFromSourceWorker.perform_async(id,UserVehicle)
    end
  end
end