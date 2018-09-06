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

  form do |user|
    # text_field :email
    text_field :name
    text_field :slack_username
    if (current_user.is_super_admin?)
      collection_select :user_role_id, UserRole.order(:name), :id, :name, include_blank: true
    end
  end

  controller do
    before_action :require_super_admin!, :except => :show
    before_action :require_self_or_admin!, :only => :update

    def require_self_or_admin!
      instance = admin.find_instance(params)
      if !current_user.is_super_admin? || current_user.id != instance.id
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
