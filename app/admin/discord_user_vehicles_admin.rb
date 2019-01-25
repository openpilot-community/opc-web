Trestle.resource(:discord_user_vehicles) do |resource|
  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  form(dialog: true) do |vehicle|
    is_new = true
    if (vehicle.persisted?)
      is_new = false
    end
    if params[:user_id]
      user = User.find(params[:user_id])
      discord_user = user.discord_user

      if (discord_user)
        vehicle.discord_user = discord_user
      end
    end
    text_field :vehicle_year, placeholder: Time.current.year, label: "Year"
    collection_select :vehicle_make, VehicleMake.order(:name), :name, :name, include_blank: true, prompt: "Honda, Toyota, Tesla, etc.", label: "Make"
    text_field :vehicle_model, placeholder: "Civic, Corolla, Prius, Model S, etc.", label: "Model"
    text_field :vehicle_trim, placeholder: "Touring, EX-L, VTi, etc.", label: "Trim"
    collection_select :vehicle_config_id,
      VehicleConfig.includes(:vehicle_make, :vehicle_model)
      .order("vehicle_makes.name, vehicle_models.name, year"), 
      :id, :name_for_selector, 
      include_blank: true,
      prompt: "Select an Openpilot Vehicle Configuration, if available.",
      label: "Linked Vehicle Configuration"
    hidden_field :discord_user_id
  end
  
  controller do
    def index
      redirect_to "/users/#{current_user.id}/edit#!tab-vehicles"
    end
  end
  # Customize the form fields shown on the new/edit views.
  #
  # form do |discord_user_vehicle|
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
  #   params.require(:discord_user_vehicle).permit(:name, ...)
  # end
end
