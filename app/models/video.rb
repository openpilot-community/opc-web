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
  has_many :vehicle_config_videos
  has_many :vehicle_configs, :through => :vehicle_config_videos
  has_many :video_hardware_items
  has_many :hardware_items, :through => :video_hardware_items
  validates_uniqueness_of :video_url, message: "Video has already been added."
  validates_uniqueness_of :html, message: "Video has already been added."
  before_validation :embed
  # has_many :hardware_items, :through => :video_hardware
  
  def name
    title
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
end
