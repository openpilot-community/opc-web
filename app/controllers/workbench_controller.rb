class WorkbenchController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::SanitizeHelper
  skip_before_action :authenticate_user!
  
  def download
    
  end
  
  def index
    # ua=request.env['HTTP_USER_AGENT'].downcase
    # client = DeviceDetector.new(ua)

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

    # @release_info = {
    #   :os_name => client.os_name,
    #   :download_link => nil
    # }
    # if client.os_name == 'Windows'
    #   file_ext = "exe"
    # elsif client.os_name == 'Mac'
    #   file_ext = "dmg"
    # elsif client.os_name == 'Linux'
    #   file_ext = "deb"
    # end
    # @release_info[:download_link] = latest_assets.find do |asset|
    #   asset.name.ends_with?(".#{file_ext}")
    # end.browser_download_url

    @releases.keys.each do |key|
      release = @releases[key]

      release[:download_link] = latest_assets.find do |asset|
        asset.name.ends_with?(".#{release[:file_ext]}")
      end.browser_download_url
      release[:os_name] = key.capitalize
    end
    title = "Download Workbench"
    author = "jfrux"
    imgurl = asset_url("/assets/workbench-icon.png")
    linkurl = "https://opc.ai/workbench"
    desc = "A desktop application for porting and managing Openpilot and EON"
    set_meta_tags(
      title: title,
      og: {
        title: title,
        image: imgurl,
        "image:width": 2482,
        "image:height": 1534,
        description: desc,
        site_name: "Openpilot Community",
        url: linkurl,
        type: "article",
        author: author
      },
      robots: "index, follow",
      # "article:published_time": ,
      "article:publisher": "https://opc.ai/",
      "article:author":  author,
      keywords: ['download','workbench', 'openpilot','vehicle','support','of','vehicles','supported','compatible','compatibility'].flatten,
      description: desc,
      canonical: linkurl,
      image_src: imgurl,
      author: author,
      twitter: {
        creator: "@#{author}",
        title: title,
        # card: "summary-large",
        description: desc,
        author: author
      }
    )
  end

end
