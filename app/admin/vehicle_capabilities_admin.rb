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
    text_field :grouping
    select(:value_type, [['State Only', "state"], ['Timeout', "timeout"], ['Speed', "speed"]])
    text_field :default_timeout
    text_field :default_string
    text_field :default_state
    text_field :default_kph
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
