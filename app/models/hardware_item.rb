# == Schema Information
#
# Table name: hardware_items
#
#  id                           :bigint(8)        not null, primary key
#  name                         :string
#  alternate_name               :string
#  description                  :text
#  hardware_type_id             :bigint(8)
#  compatible_with_all_vehicles :boolean
#  available_for_purchase       :boolean
#  purchase_url                 :string
#  requires_assembly            :boolean
#  can_be_built                 :boolean
#  build_plans_url              :string
#  notes                        :text
#  image_url                    :string
#  install_guide_url            :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class HardwareItem < ApplicationRecord
  extend FriendlyId
  include PgSearch
  pg_search_scope :search_for, :against => {
                    :name => 'A',
                    :alternate_name => 'B',
                    :description => 'C'
                  },
                  :using => {
                    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
                  }
  multisearchable :against => [:name, :alternate_name]
  has_one_attached :image
  friendly_id :name, use: :slugged
  belongs_to :hardware_type, optional: true
  after_save :set_image_scraper
  has_many :guide_hardware_items
  has_many :guides, :through => :guide_hardware_items
  has_many :video_hardware_items
  has_many :videos, :through => :video_hardware_items
  
  before_save :set_markup
  
  def set_image_scraper
    if saved_change_to_source_image_url?
      DownloadImageFromSourceWorker.perform_async(id,HardwareItem)
    end
  end

  def set_markup
    if self.description.present?
      self.description_markup = Octokit.markdown(self.description, :mode => "gfm", :context => "commaai/openpilot")
    end
  end
  def as_json(options={})
    imgurl = self.image.present? ? self.image_url : nil
    lines = []
    fields = []

    if self.purchase_url
      fields << {
        name: "Purchase",
        value: self.purchase_url
      }
    end

    # if vehicle_config_type.present?
    #   difficulty = vehicle_config_type.name
    #   fields << {
    #     name: "Difficulty",
    #     value: difficulty
    #   }
    # end
    # if vehicle_config_status.present?
    #   status = vehicle_config_status.name
    #   fields << {
    #     name: "Status",
    #     value: status
    #   }
    # end
    # if primary_repository.present?
    #   latest_repo = primary_repository.blank? ? nil : primary_repository
    #   latest_repo_branch = primary_repository.repository_branches.blank? ? nil : primary_repository.repository_branches.first
    #   if latest_repo.present?
    #     fields << {
    #       name: "Primary Repository",
    #       value: "https://github.com/#{latest_repo.name}"
    #     }
    #   end

    #   if latest_repo_branch.present?
    #     fields << {
    #       name: "Branch",
    #       value: "#{latest_repo_branch.name}"
    #     }
    #   end
    # end

    {
      id: id,
      title: self.name,
      body: self.description,
      image: imgurl,
      fields: fields
    }
  end
  # has_many :vehicle_config_hardware_items
  # has_many :video_hardware_items
  # has_many :videos, :through => :video_hardware
  # has_many :vehicle_configs, :through => :vehicle_config_hardware_items
end 
