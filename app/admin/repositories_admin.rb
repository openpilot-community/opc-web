Trestle.resource(:repositories) do
  menu do
    item :repositories, icon: "fa fa-github", group: :development, badge: Repository.all.count
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :avatar do |repo|
      image_tag(repo.owner_avatar_url, width: "50")
    end
    column :name
    
    # actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |repository|
  #   text_field :name
  #
  #   row do
  #     col(xs: 6) { datetime_field :updated_at }
  #     col(xs: 6) { datetime_field :created_at }
  #   end
  # end

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
