Trestle.resource(:releases) do
  
  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  search do |query|
    if query
      Release.search_for("#{query}")
    else
      Release.order(:updated_at => :desc)
    end
  end
  form(dialog: true) do |release_feature|
    text_field :name
  end
  # Customize the form fields shown on the new/edit views.
  #
  # form do |release|
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
  #   params.require(:release).permit(:name, ...)
  # end
end
