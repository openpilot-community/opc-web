class Release < ApplicationRecord
  has_many :release_features, autosave: true
  include PgSearch
  pg_search_scope :search_for, :against => {
                    :name => 'A'
                  },
                  :using => {
                    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
                  }
  multisearchable :against => [:name]
end
