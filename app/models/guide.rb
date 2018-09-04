class Guide < ApplicationRecord
  extend FriendlyId
  include Hashid::Rails
  has_paper_trail
  paginates_per 400
  acts_as_commontable dependent: :destroy
  has_one_attached :image
  friendly_id :name_for_slug, use: :slugged
  belongs_to :user
  before_save :find_first_image
  before_save :set_markup
  after_save :set_image_scraper
  after_commit :update_slug

  def update_slug
    unless slug.blank? || slug.ends_with?(self.hashid.downcase)
      self.slug = nil
      # byebug
      self.save
    end
  end
  
  def friendly_date
    if created_at.year == Date.today.year
      created_at.strftime("%b %d")
    else
      created_at.strftime("%b %d, %Y")
    end
  end

  def word_count
    ActionView::Base.full_sanitizer.sanitize(markup).split.size
  end

  def reading_time
    (word_count / 200.0).ceil
  end 

  def text
    sanitize(markup)
  end

  def find_first_image
    first_image = self.markdown[/(https:\/\/)(.*).(jpeg|jpg|gif|png)/]
    # first_image = markdown[/^http(s?):\/\/.*\.(jpeg|jpg|gif|png)/]
    if first_image.present?
      self.source_image_url = first_image
    end
  end
  def set_image_scraper
    if saved_change_to_source_image_url?
      puts "Queuing image download..."
      DownloadImageFromSourceWorker.perform_async(id,Guide)
    end
  end

  def name
    title
  end
  
  def set_markup
    markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    self.markup = markdown_renderer.render(self.markdown)
  end

  def name_for_slug
    "#{self.title} #{self.hashid if self.id.present?}"
  end

  # def embed
  #   iframely = Iframely::Requester.new api_key: ENV['IFRAMELY_KEY']

  #   result = iframely.get_iframely_json(self.article_source_url)

  #   if self.created_at.blank?
  #     d = DateTime.parse(result["meta"]["date"])
  #     self.created_at = d
  #   end

  #   if self.title.blank?
  #     self.title = result['meta']['title']
  #   end

  #   # puts self.thumbnail_url
  #   if self.source_image_url.blank?
  #     if result['links']['thumbnail'].is_a? Array
  #       self.source_image_url = result['links']['thumbnail'].first['href']
  #     else
  #       self.source_image_url = result['links']['thumbnail']['href']
  #     end
  #   end

  #   # if self.author_url.blank?
  #   #   self.author_url = result['meta']['author_url']
  #   # end

  #   if self.author.blank?
  #     self.author = result['meta']['author']
  #   end

  #   # if self.provider_name.blank?
  #   #   self.provider_name = result['meta']['site']
  #   # end

  #   # if self.description.blank?
  #   #   self.description = result['meta']['description']
  #   # end
  # end
end
