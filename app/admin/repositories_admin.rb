Trestle.resource(:repositories) do
  menu do
    item :repositories, icon: "fa fa-github", group: :development, priority: 2
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :avatar do |repo|
      image_tag(repo.owner_avatar_url, width: "50")
    end
    column :name, link: true
    
    # actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |repository|
    tab :general do
      text_field :name
      text_field :full_name
      text_field :owner_login
      text_field :owner_avatar_url
      text_field :url
    end
    tab :branches do
      table repository.repository_branches.order('name'), admin: :repository_branches do
        column :name
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
  #   params.require(:repository).permit(:name, ...)
  # end
end
