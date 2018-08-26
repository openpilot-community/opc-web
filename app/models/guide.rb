class Guide < ApplicationRecord
  has_paper_trail
  paginates_per 400
  # default_scope { includes(:vehicle_make, :vehicle_model, :vehicle_config_type).where(parent_id: nil).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level") }
  extend FriendlyId
  friendly_id :name_for_slug, use: :slugged
  belongs_to :user
  before_save :set_markup

  def name
    title
  end
  
  def set_markup
    markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    self.markup = markdown_renderer.render(self.markdown)
  end

  def name_for_slug
    "#{id} #{title}"
  end
end
