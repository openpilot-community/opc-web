class Image < ApplicationRecord
  acts_as_likeable
  has_one_attached :attachment
  
end
