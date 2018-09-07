class Guide < ApplicationRecord
  extend FriendlyId
  include Hashid::Rails
  has_paper_trail
  acts_as_likeable
  paginates_per 400
  acts_as_commontable dependent: :destroy
  has_one_attached :image
  friendly_id :name_for_slug, use: :slugged
  belongs_to :user, optional: true
  has_many :vehicle_config_guides, dependent: :delete_all
  has_many :guide_hardware_items, :validate => false, dependent: :delete_all
  has_many :hardware_items, :through => :guide_hardware_items, :validate => false, dependent: :delete_all
  has_many :vehicle_configs, :through => :vehicle_config_guides
  before_save :guide_from_url
  before_save :find_first_image
  before_save :set_markup
  after_save :set_image_scraper
  after_commit :update_slug
  validates_uniqueness_of :article_source_url, :on => :create
  
  def hardware_item_ids=(ids)
    self.hardware_items = Array(ids).reject(&:blank?).map { |id|
      (id =~ /^\d+$/) ? HardwareItem.friendly.find(id) : HardwareItem.find_or_initialize_by(name: id)
    }
  end

  def vehicle_config_ids=(ids)
    self.vehicle_configs = Array(ids).reject(&:blank?).map { |id|
      (id =~ /^\d+$/) ? VehicleConfig.friendly.find(id) : nil
    }
  end

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
    if self.source_image_url.blank? && self.markdown.present?
      first_image = self.markdown[/(https:\/\/)(.*).(jpeg|jpg|gif|png)/]
      # first_image = markdown[/^http(s?):\/\/.*\.(jpeg|jpg|gif|png)/]
      if first_image.present?
        self.source_image_url = first_image
      end
    end
  end

  def set_image_scraper
    if saved_change_to_source_image_url?
      puts "Queuing image download..."
      DownloadImageFromSourceWorker.perform_async(id,Guide)
    end
  end

  def parse_with_mercury(article_url)
    require 'net/http'
    require 'uri'

    uri = URI.parse("https://mercury.postlight.com/parser?url=#{article_url}")
    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = ENV['MERCURY_API_KEY']

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def parse_with_heckyesmarkdown(article_url)
    require 'net/http'
    require 'uri'

    uri = URI.parse("http://heckyesmarkdown.com/go/?u=#{article_url}&output=json")
    request = Net::HTTP::Get.new(uri)

    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def guide_from_url
    unless saved_change_to_article_source_url?
      return
    end
    mercury_parse = parse_with_mercury(article_source_url)
    heckyesmarkdown_parse = parse_with_heckyesmarkdown(article_source_url)
    
    self.title = mercury_parse['title'].present? ? mercury_parse['title'] : heckyesmarkdown_parse['title']
    self.markdown = ReverseMarkdown.convert(mercury_parse['content'].present? ? mercury_parse['content'] : heckyesmarkdown_parse['content'])
    self.source_image_url = mercury_parse['lead_image_url']
    self.author_name = mercury_parse['author'].present? ? mercury_parse['author'] : mercury_parse['domain']
    self.exerpt = mercury_parse['exerpt']
    self.published_at = mercury_parse['date_published'].present? ? mercury_parse['date_published'] : Date.today
    self.reference_domain = mercury_parse['domain']

    if self.title.blank?
      self.title = "Untitled Guide from #{self.reference_domain}"
    end
    check_author
  end

  def name
    title
  end

  def check_author
    if author_name.present?
      found_user = User.where(github_username: author_name).or(User.where(slack_username: author_name))
      if found_user.present?
        self.user_id = found_user.first.id
      end
    end
  end
  
  def set_markup
    if self.markdown.present?
      markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      self.markup = markdown_renderer.render(self.markdown)
    end
  end

  def name_for_slug
    "#{self.title} #{self.hashid if self.id.present?}"
  end
end
