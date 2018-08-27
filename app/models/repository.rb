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
  has_many :vehicle_config_repositories
  has_many :vehicle_configs, :through => :vehicle_config_repositories
  has_many :repository_branches

  def name
    full_name
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
