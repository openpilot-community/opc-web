class UserVehicle < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle_config
  belongs_to :vehicle_trim
  belongs_to :vehicle_trim_style, optional: true
  has_one_attached :image
  after_save :set_image_scraper
def name
  "#{user.github_username}'s #{vehicle_trim.year} #{vehicle_config.vehicle_make.name} #{vehicle_trim.vehicle_model.name}"
end
  def set_image_scraper
    if saved_change_to_source_image_url?
      DownloadImageFromSourceWorker.perform_async(id,UserVehicle)
    end
  end
end