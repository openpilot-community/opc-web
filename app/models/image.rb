class Image < ApplicationRecord
  acts_as_likeable
  has_one_attached :attachment
  include Rails.application.routes.url_helpers

  def attachment_url
    rails_blob_url(attachment)
  end
end
