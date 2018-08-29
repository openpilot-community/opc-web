class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if !record.new_record?
      dupes = VehicleLookup.where(%(
          vehicle_lookups.year = :year AND 
          vehicle_lookups.vehicle_make_id = :vehicle_make AND 
          vehicle_lookups.vehicle_model_id = :vehicle_model AND
          vehicle_lookups.id != :current_id
      ), {
        year: record.year,
        vehicle_make: record.vehicle_make_id,
        vehicle_model: record.vehicle_model_id,
        current_id: record.id
      }).count
    else
      dupes = VehicleLookup.where(%(
        vehicle_lookups.year = :year AND 
        vehicle_lookups.vehicle_make_id = :vehicle_make AND 
        vehicle_lookups.vehicle_model_id = :vehicle_model
      ), {
        year: record.year,
        vehicle_make: record.vehicle_make_id,
        vehicle_model: record.vehicle_model_id
      }).count
    end

    if dupes > 0
      record.errors[:vehicle_model] << "Scan complete and we've found a record that matches your query."
    end
  end
end

class VehicleLookup < ApplicationRecord
  include Scraper
  extend FriendlyId
  friendly_id :name_for_slug, use: :slugged
  has_one_attached :image
  belongs_to :vehicle_make
  belongs_to :vehicle_model
  belongs_to :vehicle_config, optional: true
  belongs_to :user, optional: true
  validates_presence_of :year, message: ""
  validates_presence_of :vehicle_make_id, message: ""
  validates_presence_of :vehicle_model_id, message: ""
  acts_as_votable
  # before_update :set_vehicle_config
  before_create :start_refreshing
  accepts_nested_attributes_for :vehicle_config
  # after_create :do_scrape_info
  validates_with GoodnessValidator

  def name_for_slug
    "#{vehicle_make.name} #{vehicle_model.name} #{year}"
  end

  def name
    "#{year} #{vehicle_make.name} #{vehicle_model.name}"
  end

  # def set_vehicle_config
  #   self.vehicle_config = VehicleConfig.find_or_initialize_by(year: year, year_end: year, vehicle_make_id: vehicle_make_id, vehicle_model_id: vehicle_model_id)
  # end

  def start_refreshing
    self.refreshing = true
  end
  # before_save
end
