Trestle.resource(:release_features) do
  
  search do |query|
    if query
      ReleaseFeature.search_for("#{query}")
    else
      ReleaseFeature.order(:updated_at => :desc)
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
  form(dialog: true) do |release_feature|
    text_field :name
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:release_feature).permit(:name, ...)
  # end
end
