class Image < ApplicationRecord
  acts_as_likeable
  has_one_attached :attachment
  include Rails.application.routes.url_helpers
  after_commit :set_dimensions
  def attachment_url
    rails_blob_url(attachment)
  end

  def set_dimensions
    if self.height.blank? || self.width.blank?
      begin
        dimensions = FastImage.new(attachment_url).size
        update_attributes(height: dimensions[1], width: dimensions[0])
      rescue

      end
    end
  end
end
