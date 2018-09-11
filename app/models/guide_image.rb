class GuideImage < ApplicationRecord
  belongs_to :guide
  belongs_to :image
  accepts_nested_attributes_for :image
  def name
    "#{guide.name} / #{image.name}"
  end

  def as_json(options={})
    {
      created_at: created_at,
      guide_id: guide_id,
      id: id,
      name: image.name,
      image_id: image_id,
      updated_at: updated_at,
      url: image.attachment_url
    }
  end
end
