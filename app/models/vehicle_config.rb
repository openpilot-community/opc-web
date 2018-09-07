
require 'open-uri'
# == Schema Information
#
# Table name: vehicle_configs
#
#  id                       :bigint(8)        not null, primary key
#  title                    :string
#  year                     :integer
#  vehicle_make_id          :bigint(8)
#  vehicle_model_id         :bigint(8)
#  vehicle_trim_id          :bigint(8)
#  vehicle_config_status_id :bigint(8)
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  vehicle_make_package_id  :bigint(8)
#  slug                     :string
#  parent_id                :integer
#  vehicle_config_type_id   :bigint(8)
#

class LookupValidator < ActiveModel::Validator
  def validate(record)
    if !record.new_record?
      dupes = VehicleConfig.where(%(
        (
          vehicle_configs.year = :year AND 
          vehicle_configs.vehicle_make_id = :vehicle_make AND 
          vehicle_configs.vehicle_model_id = :vehicle_model AND
          vehicle_configs.id != :current_id
        ) OR (
          vehicle_configs.year_end = :year AND 
          vehicle_configs.vehicle_make_id = :vehicle_make AND 
          vehicle_configs.vehicle_model_id = :vehicle_model AND
          vehicle_configs.id != :current_id
        ) OR (
          vehicle_configs.year_end = :year AND 
          vehicle_configs.vehicle_make_id = :vehicle_make AND 
          vehicle_configs.vehicle_model_id = :vehicle_model AND
          vehicle_configs.id != :current_id
        ) OR (
          vehicle_configs.year_end = :year_end AND 
          vehicle_configs.vehicle_make_id = :vehicle_make AND 
          vehicle_configs.vehicle_model_id = :vehicle_model AND
          vehicle_configs.id != :current_id
        ) OR (
          ((:year) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
          vehicle_configs.vehicle_make_id = :vehicle_make AND 
          vehicle_configs.vehicle_model_id = :vehicle_model AND
          vehicle_configs.id != :current_id
        ) OR (
          ((:year_end) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
          vehicle_configs.vehicle_make_id = :vehicle_make AND 
          vehicle_configs.vehicle_model_id = :vehicle_model AND
          vehicle_configs.id != :current_id
        )
      ), {
        year: record.year,
        year_end: record.year_end,
        vehicle_make: record.vehicle_make_id,
        vehicle_model: record.vehicle_model_id,
        current_id: record.id
      }).count
      else
        dupes = VehicleConfig.where(%(
          (
            vehicle_configs.year = :year AND 
            vehicle_configs.vehicle_make_id = :vehicle_make AND 
            vehicle_configs.vehicle_model_id = :vehicle_model
          ) OR (
            vehicle_configs.year_end = :year AND 
            vehicle_configs.vehicle_make_id = :vehicle_make AND 
            vehicle_configs.vehicle_model_id = :vehicle_model
          ) OR (
            vehicle_configs.year_end = :year AND 
            vehicle_configs.vehicle_make_id = :vehicle_make AND 
            vehicle_configs.vehicle_model_id = :vehicle_model
          ) OR (
            vehicle_configs.year_end = :year_end AND 
            vehicle_configs.vehicle_make_id = :vehicle_make AND 
            vehicle_configs.vehicle_model_id = :vehicle_model
          ) OR (
            ((:year) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
            vehicle_configs.vehicle_make_id = :vehicle_make AND 
            vehicle_configs.vehicle_model_id = :vehicle_model
          ) OR (
            ((:year_end) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
            vehicle_configs.vehicle_make_id = :vehicle_make AND 
            vehicle_configs.vehicle_model_id = :vehicle_model
          )
        ), {
          year: record.year,
          year_end: record.year_end,
          vehicle_make: record.vehicle_make_id,
          vehicle_model: record.vehicle_model_id
        }).count
      end

    if dupes > 0
      record.errors[:vehicle_model] << "The year, make, model you entered is already contained within an existing vehicle config."
    end
  end
end
class VehicleConfig < ApplicationRecord
  extend FriendlyId
  include Hashid::Rails
  include ActiveSupport::Inflector
  has_one_attached :image
  acts_as_mentionable
  acts_as_votable
  acts_as_followable
  acts_as_likeable
  has_paper_trail
  paginates_per 10
  friendly_id :name_for_slug, use: [:slugged]

  # BELONGS TO
  belongs_to :vehicle_make
  belongs_to :vehicle_model
  belongs_to :vehicle_config_status, :optional => true
  belongs_to :vehicle_make_package, :optional => true
  belongs_to :vehicle_config_type, :optional => true
  belongs_to :primary_repository, :class_name => "Repository", :foreign_key => :primary_repository_id, :optional => true
  belongs_to :primary_pull_request, :class_name => "PullRequest", :foreign_key => :primary_pull_request_id, :optional => true
  
  # HAS MANY
  has_many :vehicle_config_modifications, dependent: :delete_all
  has_many :modifications, :through => :vehicle_config_modifications
  has_many :vehicle_config_hardware_items, dependent: :delete_all
  has_many :vehicle_config_capabilities, dependent: :delete_all
  has_many :vehicle_config_guides, dependent: :delete_all
  has_many :guides, :through => :vehicle_config_guides
  has_many :vehicle_capabilities, :through => :vehicle_config_capabilities
  has_many :vehicle_config_repositories, dependent: :delete_all
  has_many :repositories, :through => :vehicle_config_repositories
  has_many :vehicle_config_pull_requests, dependent: :delete_all
  has_many :pull_requests, :through => :vehicle_config_pull_requests
  has_many :vehicle_config_videos, dependent: :delete_all

  before_validation :set_year_end
  before_save :set_trim_styles_count
  before_create :set_refreshing
  before_validation :set_title

  validates_numericality_of :year
  validates_with LookupValidator, on: :create
  validates_presence_of :year
  validates_presence_of :vehicle_make_id
  validates_presence_of :vehicle_model_id
  after_save :set_image_scraper
  after_commit :update_slug
  
  def set_refreshing
    self.refreshing = true
  end

  def update_slug
    if slug.blank? || !slug.ends_with?(self.hashid.downcase)
      self.slug = nil
      # byebug
      self.save
    end
  end
  
  def set_image_scraper
    if saved_change_to_source_image_url?
      puts "IMAGE SCRAPER"
      DownloadImageFromSourceWorker.perform_async(id,VehicleConfig)
    else
      if new_record? || !image.attached?
        ScrapeCarImageWorker.perform_async(id)
      end
    end
  end

  def self.find_by_ymm(year, make, model)
    results = where(%(
      (
        vehicle_configs.year = :year AND 
        vehicle_configs.vehicle_make_id = :vehicle_make AND 
        vehicle_configs.vehicle_model_id = :vehicle_model
      ) OR (
        ((:year) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
        vehicle_configs.vehicle_make_id = :vehicle_make AND 
        vehicle_configs.vehicle_model_id = :vehicle_model
      )
    ), {
      year: year,
      vehicle_make: make,
      vehicle_model: model
    })
    # byebug
  end
  
  def total_votes
    cached_votes_score
  end

  def has_capability?(cap_id)
    vehicle_capabilities.exists?(id: cap_id)
  end

  def config_type_ids
    vehicle_config_capabilities.includes(:vehicle_config_type).order("vehicle_config_types.difficulty_level").map(&:vehicle_config_type_id).uniq
  end
  def as_json(options={})
    {
      id: id,
      owners: user_count,
      votes: cached_votes_score
    }
  end

  def difficulty_class
    case vehicle_config_type.name
    when "Advanced"
      "danger"
    when "Easy"
      "info"
    when "Intermediate"
      "warning"
    else
      "danger"
    end
  end

  def name_for_slug
    if id.present? && year && vehicle_make && vehicle_model
      "#{year} #{vehicle_make.name} #{vehicle_model.name} #{self.hashid.downcase}"
    end
  end

  def is_upstreamed?
    if !vehicle_config_status.blank?
      vehicle_config_status.name == 'Upstreamed'
    end
  end

  def is_community_supported?
    if !vehicle_config_status.blank?
      vehicle_config_status.name == 'Community'
    end
  end
  
  def is_pull_request?
    if !vehicle_config_status.blank?
      vehicle_config_status.name == 'Pull Request'
    end
  end
  
  def is_in_development?
    if !vehicle_config_status.blank?
      vehicle_config_status.name == 'In Development'
    end
  end

  def status_classes
    if primary_repository.present?
      latest_repo = primary_repository.blank? ? nil : primary_repository
      latest_repo_branch = primary_repository.repository_branches.blank? ? nil : primary_repository.repository_branches.first

      if vehicle_config_status.present? && latest_repo.present?
        case vehicle_config_status.name
        when "Community"
          {
            :icon => "fa fa-users",
            :color => "danger",
            :url => latest_repo.blank? ? nil : latest_repo.url,
            :tooltip => "Community Supported in #{latest_repo.blank? ? nil : latest_repo.full_name}",
            :label => "#{latest_repo.blank? ? nil : latest_repo.full_name}"
          }
        when "In Development"
          {
            :icon => "fa fa-code",
            :color => "warning",
            :tooltip => vehicle_config_status.name,
            :url => (!latest_repo.blank?) ? latest_repo.url : nil,
            :label => (!latest_repo.blank?) ? "#{latest_repo.full_name}" : nil
          }
        when "Pull Request"
          {
            :icon => "fa fa-hourglass",
            :color => "info",
            :tooltip => (!primary_pull_request.blank?) ? "#{vehicle_config_status.name} ##{primary_pull_request.number}" : vehicle_config_status.name,
            :url => (!primary_pull_request.blank?) ? primary_pull_request.html_url : nil,
            :label => (!latest_repo.blank?) ? "#{latest_repo.full_name}" : nil,
          }
        when "Upstreamed"
          {
            :icon => "fa fa-check",
            :color => "success",
            :tooltip => "Upstreamed to commaai/openpilot",
            :url => (!latest_repo.blank?) ? latest_repo.url : nil,
            :label => (!latest_repo.blank?) ? "#{latest_repo.full_name}" : nil,
          }
        when "Researching"
          {
            :icon => "fa fa-globe",
            :color => "default",
            :tooltip => vehicle_config_status.name.downcase,
            :url => "#",
            :label => "Researching"
          }
        when "Archived"
          {
            :icon => "fa fa-archive",
            :color => "default",
            :tooltip => vehicle_config_status.name.downcase,
            :url => "#",
            :label => "fa fa-archive"
          }
        else
          {
            :icon => "fa fa-globe",
            :color => "default",
            :tooltip => "Researching",
            :url => "#",
            :label => "Researching"
          }
        end
      else
        {
          :icon => "fa fa-globe",
          :color => "default",
          :tooltip => "Researching",
          :url => "#",
          :label => "Researching"
        }
      end
    else
      {
        :icon => "fa fa-globe",
        :color => "default",
        :tooltip => "Researching",
        :url => "#",
        :label => "Researching"
      }
    end
  end

  def set_year_end
    if year.to_i > year_end.to_i
      self.year_end = self.year.to_i
    end
  end

  def name
    new_name = "Untitled"
    if vehicle_make && vehicle_model
      new_name = "#{year_range_str} #{vehicle_make.name} #{vehicle_model.name}"
      
    end

    new_name
  end

  def has_year_end?
    !self.year_end.blank?
  end

  def year_range=(ystart, year_end)
    if !ystart.blank? && !yend.blank?
      self.year = ystart
      self.year_end = yend
    elsif ystart.blank? && !yend.blank?
      self.year = yend
      self.year_end = yend
    elsif !ystart.blank? && yend.blank?
      self.year = ystart
      self.year_end = ystart
    else
      self.year = nil
      self.year_end = nil
    end
  end

  def year_range
    if !year.blank? && !year_end.blank?
      if (year <= year_end)
        (year..year_end)
      else
        (year..year)
      end
    elsif year.blank? && !year_end.blank?
      (year_end..year_end)
    elsif !year.blank? && year_end.blank?
      (year..year)
    else
      (1917..1917)
    end
  end

  def year_range_str
    if has_year_end? && year != year_end
      "#{year}-#{year_end}"
    elsif has_year_end? && year.blank?
      "#{year_end}"
    else
      "#{year}"
    end
  end

  def vehicle_trim_ids=(ids)
    self.vehicle_trims = Array(ids).reject(&:blank?).map do |id|
      (id =~ /^\d+$/) ? VehicleTrim.find(id) : VehicleTrim.new(name: id, vehicle_model: self.vehicle_model)
    end
  end
  
  def vehicle_trim_names
    vehicle_trims.map(&:name).join(", ")
  end
  
  def has_parent?
    !self.parent.blank?
  end
  
  def capability_count
    vehicle_capabilities.size
  end

  def is_factory?
    vehicle_config_type.name == 'Factory'
  end

  def is_standard?
    vehicle_config_type.name == 'Standard'
  end

  def is_basic?
    vehicle_config_type.name == 'Basic'
  end

  def set_trim_styles_count
    if parent_id.blank?
      if !trim_styles.blank? && trim_styles.count > 0
        self.trim_styles_count = trim_styles.count
      else
        self.trim_styles_count = 0
      end
    end
  end


  def trim_styles
    VehicleTrimStyle.joins(:vehicle_trim).where('vehicle_trims.year IN (:years) AND vehicle_trim_id IN (:trim_ids)',{ :years => year_range, :trim_ids => vehicle_model.vehicle_trims.map(&:id) }).order("vehicle_trims.year, vehicle_trims.sort_order, vehicle_trim_styles.name")
  end

  def set_title
    self.title = "#{year_range_str} #{vehicle_make.name} #{vehicle_model.name}"
  end
end
