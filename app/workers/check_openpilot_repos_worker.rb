require 'sidekiq-scheduler'
class CheckOpenpilotReposWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something later
    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    client.auto_paginate = true

    forks = client.forks('commaai/openpilot')
    forks.each do |fork|
      new_repo = Repository.find_or_initialize_by(:full_name => fork.full_name)
      new_repo.name = fork.name
      new_repo.full_name = fork.full_name
      new_repo.owner_login = fork.owner.login
      new_repo.owner_avatar_url = fork.owner.avatar_url
      new_repo.owner_url = fork.owner.url
      new_repo.url = fork.html_url
      new_repo.save!
    end
  end
end