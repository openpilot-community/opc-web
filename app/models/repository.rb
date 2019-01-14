# == Schema Information
#
# Table name: repositories
#
#  id               :bigint(8)        not null, primary key
#  name             :string
#  full_name        :string
#  owner_login      :string
#  owner_avatar_url :string
#  owner_url        :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Repository < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper
  has_many :vehicle_config_repositories
  has_many :vehicle_configs, :through => :vehicle_config_repositories
  has_many :repository_branches
  include PgSearch
  pg_search_scope :search_for, :against => {
      :full_name => 'A',
      :owner_login => 'B',
      :name => 'C'
    },
    :using => {
      :tsearch => {:prefix => true, :any_word => true}
    }
  multisearchable :against => [:full_name, :owner_login, :name]
  def name
    full_name
  end
  def author
    if owner_login.present?
      {
        name: owner_login,
        url: owner_url,
        image: owner_avatar_url
      }
    end
  end
  def as_json(options={})
    imgurl = self.owner_avatar_url

    {
      id: id,
      image: File.join(Rails.application.routes.url_helpers.root_url,asset_url("assets/github-logo.png")),
      author: author,
      title: self.full_name,
      url: url,
      body: "`git clone #{url}.git`"
    }
  end
  def scrape_branches
    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    client.auto_paginate = true
    gh_branches = client.branches(self.full_name)
    gh_branches.each do |branch|
      new_branch = self.repository_branches.find_or_initialize_by(name: branch.name)

      new_branch.save!
    end
  end
end
