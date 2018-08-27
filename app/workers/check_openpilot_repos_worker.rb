require 'sidekiq-scheduler'
class CheckOpenpilotReposWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something later
    
    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    client.auto_paginate = true
    forks = client.forks('commaai/openpilot');
    commaai_repo = Repository.find_or_initialize_by(:full_name => 'commaai/openpilot')
    commaai_repo.scrape_branches
    forks.each do |fork|
      new_repo = Repository.find_or_initialize_by(:full_name => fork.full_name)
      new_repo.name = fork.name
      new_repo.full_name = fork.full_name
      new_repo.owner_login = fork.owner.login
      new_repo.owner_avatar_url = fork.owner.avatar_url
      new_repo.owner_url = fork.owner.url
      new_repo.url = fork.html_url
      new_repo.save!
      begin
        branches = client.branches(new_repo.full_name)

        branches.each do |branch|
          new_branch = new_repo.repository_branches.find_or_initialize_by(name: branch.name)

          new_branch.save!
        end
      rescue
        puts "Failed to fetch branches..."
      end


    end
  end
end