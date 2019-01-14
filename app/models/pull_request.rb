# == Schema Information
#
# Table name: pull_requests
#
#  id                 :bigint(8)        not null, primary key
#  name               :string
#  number             :string
#  title              :string
#  state              :string
#  locked             :string
#  user               :string
#  body               :string
#  pr_created_at      :string
#  pr_updated_at      :string
#  closed_at          :string
#  merged_at          :string
#  merge_commit_sha   :string
#  head               :string
#  author_association :string
#  html_url           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class PullRequest < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper
  has_many :vehicle_config_pull_requests
  has_many :vehicle_configs, :through => :vehicle_config_pull_requests
  include PgSearch
  pg_search_scope :search_for, :against => {
                    :name => 'A',
                    :title => 'B',
                    :body => 'C'
                  },
                  :using => {
                    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
                  }
  multisearchable :against => [:name, :title, :body]
  def vehicles
    if !vehicle_configs.blank?
      vehicle_configs.map(&:name).join(", ")
    end
  end
  def author
    if user.present?
      {
        name: user,
        url: "https://github.com/#{user}"
      }
    end
  end
  def as_json(options={})
    lines = []
    fields = []
    fields << {
      name: "Number",
      value: "##{self.number}"
    }
    fields << {
      name: "Status",
      value: self.state
    }
    if self.pr_created_at
      fields << {
        name: "Created",
        value: self.pr_created_at
      }
    end
    if self.pr_updated_at
      fields << {
        name: "Last Update",
        value: self.pr_updated_at
      }
    end
    if merged_at
      fields << {
        name: "Merged Date",
        value: self.merged_at
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
      title: "#{self.title} ##{self.number}",
      body: self.body,
      author: self.author,
      fields: fields,
      image: File.join(Rails.application.routes.url_helpers.root_url,asset_url("assets/github-logo.png")),
      url: self.html_url
    }
  end
end
