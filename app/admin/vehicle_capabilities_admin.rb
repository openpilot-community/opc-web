Trestle.resource(:vehicle_capabilities) do
  
  scope :all, -> { VehicleCapability.order("name") }, default: true
  
  table do
    column :name, link: true
    column :description
    # actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |vehicle_capability|
    text_field :name
    editor :description
    # row do
    #   col(xs: 6) { datetime_field :updated_at }
    #   col(xs: 6) { datetime_field :created_at }
    # end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:vehicle_capability).permit(:name, ...)
  # end
end
