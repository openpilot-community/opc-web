# == Schema Information
#
# Table name: videos
#
#  id            :bigint(8)        not null, primary key
#  title         :string
#  video_url     :string
#  provider_name :string
#  author        :string
#  author_url    :string
#  thumbnail_url :string
#  description   :string
#  html          :string
#  uploaded_at   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Video < ApplicationRecord
  extend FriendlyId
  include PgSearch
  include Hashid::Rails
  pg_search_scope :search_for, :against => {
    :title => 'A',
    :description => 'B',
    :author => 'C'
  },
  :using => {
    :tsearch => {:highlight => true, :any_word => true, :dictionary => "english"}
  }
  multisearchable :against => [:title, :description, :author]
  friendly_id :name_for_slug, use: :slugged
  has_many :vehicle_config_videos
  has_many :vehicle_configs, :through => :vehicle_config_videos
  has_many :video_hardware_items
  has_many :hardware_items, :through => :video_hardware_items
  validates_uniqueness_of :video_url, message: "Video has already been added."
  validates_uniqueness_of :html, message: "Video has already been added."
  validates_uniqueness_of :title, scope: :author, message: "Video has already been added."
  before_validation :embed
  after_commit :update_slug

  def hardware_item_ids=(ids)
    self.hardware_items = Array(ids).reject(&:blank?).map { |id|
      (id =~ /^\d+$/) ? HardwareItem.find(id) : HardwareItem.new(name: id)
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
    if uploaded_at.year == Date.today.year
      uploaded_at.strftime("%b %d")
    else
      uploaded_at.strftime("%b %d, %Y")
    end
  end
  def as_json(options={})
    # imgurl = self.latest_image.present? ? self.latest_image.attachment_url : File.join(Rails.application.routes.url_helpers.root_url,asset_url("/assets/og/tracker.png"))
    
    {
      id: id,
      image: thumbnail_url,
      title: title,
      body: description,
      slug: slug,
      author: {
        name: self.author,
        url: self.author_url
      }
    }
  end
  def name
    title
  end

  def name_with_author
    "[#{author}] #{title}"
  end

  def embed
    iframely = Iframely::Requester.new api_key: ENV['IFRAMELY_KEY']

    result = iframely.get_iframely_json(self.video_url)

    if self.uploaded_at.blank?
      d = DateTime.parse(result["meta"]["date"])
      self.uploaded_at = d
    end

    if self.title.blank?
      self.title = result['meta']['title']
    end

    # puts self.thumbnail_url
    if self.thumbnail_url.blank?
      if result['links']['thumbnail'].is_a? Array
        self.thumbnail_url = result['links']['thumbnail'].first['href']
      else
        self.thumbnail_url = result['links']['thumbnail']['href']
      end
    end
    if self.html.blank?
      self.html = result['html']
    end
    if self.author_url.blank?
      self.author_url = result['meta']['author_url']
    end

    if self.author.blank?
      self.author = result['meta']['author']
    end

    if self.provider_name.blank?
      self.provider_name = result['meta']['site']
    end

    if self.description.blank?
      self.description = result['meta']['description']
    end
  end

  
  def name_for_slug
    "#{self.title} #{self.hashid if self.id.present?}"
  end
end
