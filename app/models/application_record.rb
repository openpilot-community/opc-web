class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  attr_accessor :full_url
end
