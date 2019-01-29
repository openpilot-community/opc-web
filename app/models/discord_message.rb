
# == Schema Information
#
# Table name: discord_message
#

#

class DiscordMessage < ApplicationRecord
  include PgSearch
  belongs_to :discord_user
  pg_search_scope :search_for, :against => {
    :content => 'A'
  }, :associated_against => {
    :discord_user => [:username]
  }, :using => {
    :tsearch => {
      :prefix => true,
      :negation => true, 
      :normalization => 2,
      :highlight => {
        :StartSel => '**',
        :StopSel => '**',
        :MaxWords => 123,
        :MinWords => 456,
        :ShortWord => 4,
        :HighlightAll => true,
        :MaxFragments => 3,
        :FragmentDelimiter => '&hellip;'
      }
    }
  }

  def name
    id
  end

  def as_json(options={})
    # imgurl = self.latest_image.present? ? self.latest_image.attachment_url : nil
    
    {
      id: id,
      # image: imgurl,
      body: content,
      slug: id,
      author: {
        id: discord_user_id,
        name: discord_user.username,
        image: discord_user.avatar
      },
      created_at: created_at,
      updated_at: updated_at
    }
  end
end