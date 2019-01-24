
require 'open-uri'
# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  username        :string
#  email           :string
#  slack_username  :string
#  github_username :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  avatar_url      :string
#

class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  default_scope -> { where(guest: false) }
  has_one_attached :avatar
  acts_as_voter
  acts_as_liker
  acts_as_mentioner
  acts_as_follower
  has_many :vehicles, :class_name => "UserVehicle"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[github discord]
  # has_one :login
  has_many :guides
  has_many :identities
  belongs_to :user_role
  has_one :discord_user
  has_many :versions, :foreign_key => :whodunnit
  # before_create :set_role

  def at_username
    "@#{github_username}"
  end

  def is_visitor?
    user_role.name == 'Visitor'
  end

  def is_editor?
    user_role.name == 'Editor'
  end
  
  def is_admin?
    user_role.name == 'Admin'
  end

  def is_super_admin?
    user_role.name == 'Super Admin'
  end

  def avatar_url
    if avatar && avatar.present?
      rails_blob_url(avatar)
    end
  rescue
    nil
  end

  

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.github_data"] && session["devise.github_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
      if data = session["devise.discord_data"] && session["devise.discord_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  
  def display_name
    if self.name.present?
      self.name
    end
  end

  def username
    github_username || discord_username
  end

  def full_name
    self.name
  end
end
