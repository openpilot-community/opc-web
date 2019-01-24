class Identity < ActiveRecord::Base
  belongs_to :user, autosave: true
  accepts_nested_attributes_for :user
  def self.from_omniauth(auth)
    new_identity = Identity.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    new_identity.user = User.find_or_initialize_by(email: auth.info.email)
    new_identity.user.email = auth.info.email
    # new_identity.user.password = Devise.friendly_token[0,20]
    new_identity.user.name = auth.info.name   # assuming the user model has a name

    if auth.provider == "github"
      new_identity.user.github_username = auth.info.nickname || auth.info.name
    end

    if auth.provider == "discord"
      new_identity.user.discord_username = auth.info.nickname || auth.info.name
    end
    if !auth.info.blank? && !auth.info.image.blank? && !new_identity.user.avatar.attached?
      # address_parsed = Addressable::URI.parse(auth.info.image)
      begin
        avatar_img_file = open(auth.info.image)
        mime_type = MimeMagic.by_magic(avatar_img_file)
        new_identity.user.avatar.attach(
          io: avatar_img_file,
          filename: "#{auth.info.nickname}.#{mime_type.extensions.last}",
          content_type: mime_type.type

        )
      rescue
        puts "Error downloading avatar..."
      end
    end
    if new_identity.user.new_record?
      is_contributor = Contributor.find_by(username: new_identity.user.github_username)
      if is_contributor
        new_identity.user.user_role = UserRole.find_by(name: "Admin")
      else
        new_identity.user.user_role = UserRole.find_by(name: "Visitor")
      end
    end
    new_identity.save
    
    new_identity
  end
  def link_to_discord_user
    if self.provider == "discord"
      discord_user = DiscordUser.find(self.uid)
      
      if (discord_user.present?)
        discord_user.user = self.user

        discord_user.save
      end
    end
  end
  def self.find_with_omniauth(auth)
    find_by(uid: auth['uid'], provider: auth['provider'])
  end

  def self.create_with_omniauth(auth)
    create(uid: auth['uid'], provider: auth['provider'])
  end
end