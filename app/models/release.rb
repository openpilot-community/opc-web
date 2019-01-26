class Release < ApplicationRecord
  has_many :release_features, autosave: true
  
end
