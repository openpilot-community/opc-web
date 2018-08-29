class CheckOpenpilotPullRequestsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => nil

  def perform(*args)
    # Do something later
    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    client.auto_paginate = true

    pull_requests = client.pull_requests('commaai/openpilot', {
      :state => "all"
    })
    
    pull_requests.each do |pr|
      new_pr = PullRequest.find_or_initialize_by(:number => pr.number)
      new_pr.name = "\##{pr.number} #{pr.title}"
      new_pr.number = pr.number 
      new_pr.title = pr.title
      new_pr.state = pr.state 
      new_pr.locked = pr.locked 
      new_pr.user = pr.head.user.login
      new_pr.body = pr.body 
      new_pr.pr_created_at = pr.created_at 
      new_pr.pr_updated_at = pr.updated_at 
      new_pr.closed_at = pr.closed_at 
      new_pr.merged_at = pr.merged_at 
      new_pr.merge_commit_sha = pr.merge_commit_sha 
      # new_pr.head = pr.head
      # new_pr.author_association = pr.author_association
      new_pr.html_url = pr.html_url 
      
      new_pr.save!
    end
  end
end
