
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
  has_one_attached :avatar
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[github]
  # has_one :login
  belongs_to :user_role
  # before_create :set_role


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

  def self.from_omniauth(auth)
    new_user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    new_user.email = auth.info.email
    # new_user.password = Devise.friendly_token[0,20]
    new_user.name = auth.info.name   # assuming the user model has a name
    new_user.github_username = auth.info.nickname
    new_user.slack_username = auth.info.nickname
    if !new_user.avatar.attached?
      # address_parsed = Addressable::URI.parse(auth.info.image)
      avatar_img_file = open(auth.info.image)
      mime_type = MimeMagic.by_magic(avatar_img_file)
      new_user.avatar.attach(
        io: avatar_img_file,
        filename: "#{auth.info.nickname}.#{mime_type.extensions.last}",
        content_type: mime_type.type

      )
    end
    if new_user.new_record?
      is_contributor = Contributor.find_by(username: new_user.github_username)
      if is_contributor
        new_user.user_role = UserRole.find_by(name: "Admin")
      else
        new_user.user_role = UserRole.find_by(name: "Visitor")
      end
    end
    new_user.save
    new_user
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.github_data"] && session["devise.github_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def name
    github_username
  end

  def full_name
    self.name
  end
end
