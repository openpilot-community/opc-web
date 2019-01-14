# == Schema Information
#
# Table name: vehicle_capabilities
#
#  id          :bigint(8)        not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class VehicleCapability < ApplicationRecord
  include CapabilityMethods
  include ActionView::Helpers::AssetUrlHelper
  extend FriendlyId
  paginates_per 400
  friendly_id :name, use: :slugged
  has_many :vehicle_config_capabilities
  has_many :vehicle_config, :through => :vehicle_config_capabilities
  include PgSearch
  pg_search_scope :search_for, :against => {
                    :name => 'A'
                  },
                  :using => {
                    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
                  }
  multisearchable :against => [:name]
  def should_generate_new_friendly_id?
    name_changed?
  end

  def timeout
    if default_timeout.present?
      default_timeout
    else
      0
    end
  end

  def kph
    if default_kph.present?
      default_kph
    else
      0
    end
  end

  def state
    if default_state.present?
      default_state
    else
      0
    end
  end

  def icon_url
    File.join(Rails.application.routes.url_helpers.root_url,asset_url("assets/capabilities/#{self.name.parameterize}.png"))
  end

  def as_json(options={})
    imgurl = self.icon_url
    lines = []
    fields = []
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
      image: imgurl
    }
  end
  # def set_defaults
  #   if self.value_type.blank?
  #     self.value_type = 'toggle' # feeds a boolean field
  #   end
  # end
  
end
