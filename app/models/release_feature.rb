class ReleaseFeature < ApplicationRecord
  belongs_to :release
  include PgSearch
  pg_search_scope :search_for, :against => {
                    :name => 'A'
                  },
                  :using => {
                    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
                  }
  multisearchable :against => [:name]

  def as_json(options={})
    {
      id: id,
      title: "#{self.release.name}",
      body: "#{self.release.release_features.map{|feature| feature.id == self.id ? "- **#{feature.name}**" : "- #{feature.name}" }.join("\n")}",
      author: {
        name: "Comma.ai",
        url: "https://github.com/commaai"
      },
      url: "https://github.com/commaai/openpilot/blob/devel/RELEASES.md"
    }
  end
end
