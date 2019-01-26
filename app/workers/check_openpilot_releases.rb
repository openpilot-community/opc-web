class CheckOpenpilotReleases
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def perform(*args)
    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    releases_file = Down.download("https://raw.githubusercontent.com/commaai/openpilot/devel/RELEASES.md")
    
    releases = releases_file.read.split(/\n\n/)
    releases.each do |release|
      splitRelease = release.split(/[\=]+/)
      title = splitRelease.first.strip.gsub(/\s+/, " ")
      version = title[/[0-9\.]+/]
      body = splitRelease.last
      features = body.split(/\s\*\s/)
      # puts "#{version}\n"
      releaseRecord = Release.find_or_initialize_by(version: version)
      releaseRecord.name = title
      releaseRecord.version = version
      features.reject{|feature| feature.blank?}.each do |feature|
        featureRecord = releaseRecord.release_features.find_or_initialize_by(name: feature.squish)
      end
      releaseRecord.save
    end
  end
end