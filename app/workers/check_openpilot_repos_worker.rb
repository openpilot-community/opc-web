require 'sidekiq-scheduler'
class CheckOpenpilotReposWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def process_fork(fork)
    begin
    client = Octokit::Client.new(:client_id => ENV['GITHUB_OPC_CLIENT_ID'], :client_secret => ENV['GITHUB_OPC_CLIENT_SECRET'])
    client.auto_paginate = false
    
    new_repo = Repository.find_or_initialize_by(:full_name => fork.full_name)
    new_repo.name = fork.name
    new_repo.full_name = fork.full_name
    new_repo.owner_login = fork.owner.login
    new_repo.owner_avatar_url = fork.owner.avatar_url
    new_repo.owner_url = fork.owner.url
    new_repo.url = fork.html_url
    new_repo.created_at = fork.created_at
    new_repo.updated_at = fork.updated_at
    new_repo.save!

    forks = client.forks(fork.full_name);

    if forks
      forks.each do |fork_of_fork|
        process_fork(fork_of_fork)
      end
    end
    #   branches = client.branches(new_repo.full_name)

    #   if branches.present?
    #     branches.each do |branch|
    #       new_branch = new_repo.repository_branches.find_or_initialize_by(name: branch.name)

    #       new_branch.save!
    #     end
    #   else
    #     puts "NO BRANCHES RETURNED FOR #{new_repo.full_name}"
    #   end
    rescue Exception => e
      puts "Failed to fetch branches...", e
    end
  end
  def perform(*args)
    # Do something later
    client = Octokit::Client.new(:client_id => ENV['GITHUB_OPC_CLIENT_ID'], :client_secret => ENV['GITHUB_OPC_CLIENT_SECRET'])
    client.auto_paginate = true
    forks = client.forks('commaai/openpilot', {
      sort: "stargazers"
    });
    # "pushed_at": "2011-01-26T19:06:43Z",
    # "created_at": "2011-01-26T19:01:12Z",
    # "updated_at": "2011-01-26T19:14:43Z",
    commaai_repo = Repository.find_or_initialize_by(:full_name => 'commaai/openpilot')
    commaai_repo.scrape_branches

    forks.each do |fork|
      process_fork(fork)
    end
  end
end