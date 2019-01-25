Trestle.resource(:users) do

  # Customize the table columns shown on the index view.
  #
  table do
    column :name
    column :vehicles do |user|
      user.vehicles.count()
    end
    column :guides do |user|
      user.guides.count()
    end
    column :versions, header: "db edits" do |user|
      user.versions.count()
    end
    column :votes do |user|
      user.votes.count()
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  scope :all, -> { User.includes(:votes, :vehicles, :guides).where(guest: false) }, default: true

  find_instance do |params|
    begin
      User.find_by(discord_username: params['id']) || User.find(params['id'])
    rescue
    end
  end

  form do |user|
    tab :general, label: '<span class="fa fa-user mr-1" style="margin-right:5px;"></span> Profile'.html_safe do
      select :openpilot_experience, [
          "Just Researching",
          "Purchased Hardware",
          "Up and running",
          "Daily Active User",
          "Customizing and Modding",
          "Vehicle Porter"
        ],
        { label: "My experience level with Openpilot is..." }, 
        { multiple: false }
      select :hardware_item_ids, HardwareItem.all.order(:name), { label: "Hardware I've already purchased and/or installed..." }, { multiple: true }
      text_field :youtube_channel_url
    end
    tab :vehicles, label: '<span class="fa fa-car mr-1" style="margin-right:5px;"></span> Garage'.html_safe, badge: instance.discord_user.discord_user_vehicles.blank? ? nil : instance.discord_user.discord_user_vehicles.size do
      render "tab_toolbar", {
        :groups => [
          {
            :class => "actions",
            :items => [
              admin_link_to("<span class=\"fa fa-plus\"></span> Add New Vehicle".html_safe, admin: :discord_user_vehicles, action: :new, class: "btn btn-default btn-list-add", params: { user_id: instance.blank? ? nil : instance.id })
            ]
          }
        ]
      }
      table instance.discord_user.discord_user_vehicles, admin: :discord_user_vehicles do
        # row do |row|
        #   {
        #     data: {
        #       url: discord_user_vehicles_admin_url(row.id)
        #     }
        #   }
        # end
        column :row do |row|
          render "admin/discord_user_vehicles/row", instance: row
        end

        # column :author
      end
    end
    tab :videos, label: '<span class="fa fa-video-camera"></span> My Videos'.html_safe, badge: instance.user_videos.blank? ? nil : instance.user_videos.size do
      render "tab_toolbar", {
        :groups => [
          {
            :class => "actions",
            :items => [
              content_tag(:span,"Add a video: ", class: "btn btn-default disabled", style: "color:#212121;"),
              admin_link_to("<span class=\"fa fa-plus\"></span> Existing".html_safe, admin: :user_videos, action: :new, class: "btn btn-default btn-list-add", params: { user_id: user.blank? ? nil : user.id }),
              admin_link_to("<span class=\"fa fa-plus\"></span> From URL".html_safe, admin: :user_videos, action: :new, class: "btn btn-default btn-list-add", params: { from_url: true, user_id: user.blank? ? nil : user.id })
            ]
          }
        ]
      }
      table instance.user_videos, admin: :user_videos do
        column :thumbnail do |user_video|
          image_tag(user_video.thumbnail_url, width: '150')
        end
        column :name
        column :author
      end
    end
    # text_field :email
    sidebar do
      if instance.avatar_url
        render inline: image_tag(instance.avatar_url, class: "profile-image")
      end
      if (current_user.is_super_admin?)
        collection_select :user_role_id, UserRole.order(:id), :id, :name, include_blank: true
      else
        static_field :opc_role, instance.user_role.name
      end
      static_field :name, instance.name
      static_field :linked_discord_username, instance.discord_username
      static_field :linked_github_username, instance.github_username
      static_field :linked_discord_user, instance.discord_user.id
    end
  end

  controller do
    # before_action :require_super_admin!, :except => :show
    before_action :authenticate_user!
    before_action :set_instance
    before_action :require_self_or_admin!, :only => [:show, :edit, :update]
    # def show
    #   self.instance = admin.find_instance(params)
      
    # end
    
    def set_instance
      instance = admin.find_instance(params)
      if instance.blank?
        redirect_to '/'
      end
    end
    def require_self_or_admin!
      
      if !current_user.is_super_admin? && current_user.id != instance.id
        render "unauthorized" 
        return
      else
        ident = instance.identities.find_by(:provider => "discord")
        if ident.present?
          Identity.link_to_discord_user(ident)
        end
      end
    end
  end
  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:user).permit(:name, ...)
  # end
end
