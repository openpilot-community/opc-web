class WorkbenchController < ApplicationController
  skip_before_action :authenticate_user!
  
  def download
    
  end
  
  def index
    ua=request.env['HTTP_USER_AGENT'].downcase
    client = DeviceDetector.new(ua)

    octokit = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    octokit.auto_paginate = false
    latest_assets = octokit.latest_release('openpilot-community/workbench').assets;
    
    @releases = {
      :mac => {
        :file_ext => "dmg"
      },
      :windows => {
        :file_ext => "exe"
      },
      :linux => {
        :file_ext => "deb"
      }
    }

    @release_info = {
      :os_name => client.os_name,
      :download_link => nil
    }
    if client.os_name == 'Windows'
      file_ext = "exe"
    elsif client.os_name == 'Mac'
      file_ext = "dmg"
    elsif client.os_name == 'Linux'
      file_ext = "deb"
    end
    @release_info[:download_link] = latest_assets.find do |asset|
      asset.name.ends_with?(".#{file_ext}")
    end.browser_download_url

    @releases.keys.each do |key|
      release = @releases[key]

      release[:download_link] = latest_assets.find do |asset|
        asset.name.ends_with?(".#{release[:file_ext]}")
      end.browser_download_url
      release[:os_name] = key.capitalize
    end
  end

end
