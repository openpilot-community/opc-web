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
    tab :general do
      static_field :name, instance.name
      static_field :discord_username, instance.discord_username
      static_field :github_username, instance.github_username
      static_field :linked_discord_user, instance.discord_user.id
      if (current_user.is_super_admin?)
        collection_select :user_role_id, UserRole.order(:name), :id, :name, include_blank: true
      end
    end
    tab :vehicles, label: '<span class="fa fa-car"></span> Vehicles'.html_safe, badge: instance.discord_user.discord_user_vehicles.blank? ? nil : instance.discord_user.discord_user_vehicles.size do
      # render "tab_toolbar", {
      #   :groups => [
      #     {
      #       :class => "actions",
      #       :items => [
      #         content_tag(:span,"Add Hardware: ", class: "btn btn-default disabled", style: "color:#212121;"),
      #         admin_link_to("<span class=\"fa fa-plus\"></span> Hardware".html_safe, admin: :vehicle_config_hardware_items, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id })
      #         # admin_link_to("<span class=\"fa fa-pencil\"></span> Write".html_safe, admin: :vehicle_config_hardware_items, action: :new, dialog: true, class: "btn btn-default btn-list-add", params: { new: true, vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id })
      #       ]
      #     }
      #   ]
      # }
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
    # text_field :email
    
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
