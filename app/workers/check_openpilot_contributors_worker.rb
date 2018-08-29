class CheckOpenpilotContributorsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def perform(*args)
    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    client.auto_paginate = false
    # "login": "octocat",
    # "id": 1,
    # "node_id": "MDQ6VXNlcjE=",
    # "avatar_url": "https://github.com/images/error/octocat_happy.gif",
    # "gravatar_id": "",
    # "url": "https://api.github.com/users/octocat",
    # "html_url": "https://github.com/octocat",
    # "followers_url": "https://api.github.com/users/octocat/followers",
    # "following_url": "https://api.github.com/users/octocat/following{/other_user}",
    # "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
    # "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
    # "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
    # "organizations_url": "https://api.github.com/users/octocat/orgs",
    # "repos_url": "https://api.github.com/users/octocat/repos",
    # "events_url": "https://api.github.com/users/octocat/events{/privacy}",
    # "received_events_url": "https://api.github.com/users/octocat/received_events",
    # "type": "User",
    # "site_admin": false,
    # "contributions": 32
    contributors = client.contributors('commaai/openpilot')
    contributors.each do |contributor|
      new_contributor = Contributor.find_or_initialize_by(:username => contributor.login)
      new_contributor.contributions = contributor.contributions
      new_contributor.html_url = contributor.html_url
      new_contributor.avatar_url = contributor.avatar_url
      new_contributor.save!
    end
  end
end
