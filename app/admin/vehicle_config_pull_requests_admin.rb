Trestle.resource(:vehicle_config_pull_requests) do
  # menu do
  #   item :vehicle_config_pull_requests, icon: "fa fa-star", group: :other
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  form(dialog:true) do |vehicle_config_pull_request|
    if vehicle_config_pull_request.vehicle_config.blank?
      if params[:vehicle_config_id]
        vehicle_config = VehicleConfig.find(params[:vehicle_config_id])
        vehicle_config_pull_request.vehicle_config = vehicle_config
      end
    else
      vehicle_config = vehicle_config_pull_request.vehicle_config
    end
    if !vehicle_config.blank?
      static_field :vehicle_config, vehicle_config.name
      
      hidden_field :vehicle_config_id
    else
      collection_select :vehicle_config_id, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :vehicle_config_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, vehicle_config_types.difficulty_level"), :id, :name, include_blank: true
    end
    collection_select :pull_request_id, PullRequest.order(:pr_updated_at => :desc), :id, :name, include_blank: true
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:vehicle_config_pull_request).permit(:name, ...)
  # end
end
