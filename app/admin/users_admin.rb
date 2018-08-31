Trestle.resource(:users) do
  menu do
    group :super_admin, priority: 1000 do
      item :users, icon: "fa fa-users"
    end
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
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
