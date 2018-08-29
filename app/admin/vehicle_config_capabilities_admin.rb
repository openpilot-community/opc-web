Trestle.resource(:vehicle_config_capabilities) do
  # menu do
  #   item :vehicle_config_capabilities, icon: "fa fa-star", group: :other
  # end

  form(dialog:true) do |vehicle_config_capability|
    # VEHICLE_CONFIG
    vehicle_config = vehicle_config_capability.vehicle_config
    if vehicle_config_capability.vehicle_config.blank?
      if params[:vehicle_config_id]
        vehicle_config = VehicleConfig.find(params[:vehicle_config_id])
        vehicle_config_capability.vehicle_config = vehicle_config
      end
    else
      vehicle_config = vehicle_config_capability.vehicle_config
    end
    if !vehicle_config.blank?
      static_field :vehicle_config, vehicle_config.name
      hidden_field :vehicle_config_id
    else
      collection_select :vehicle_config_id, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :vehicle_config_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, vehicle_config_types.difficulty_level"), :id, :name, include_blank: true
    end

    # VEHICLE_CONFIG_CAPABILITY
    if vehicle_config_capability.vehicle_config_type.blank?
      if params[:vehicle_config_type_id]
        vehicle_config_type = VehicleConfigType.find(params[:vehicle_config_type_id])
        vehicle_config_capability.vehicle_config_type = vehicle_config_type
      end
    else
      vehicle_config_type = vehicle_config_capability.vehicle_config_type
    end
    if !vehicle_config_type.blank?
      static_field :vehicle_config_type, vehicle_config_type.name
      hidden_field :vehicle_config_type_id
    else
      collection_select :vehicle_config_type_id, VehicleConfigType.order(:name), :id, :name, include_blank: true
    end

    # VEHICLE_CONFIG_CAPABILITY
    if vehicle_config_capability.vehicle_capability.blank?
      if params[:vehicle_capability_id]
        vehicle_capability = VehicleCapability.find(params[:vehicle_capability_id])
        vehicle_config_capability.vehicle_capability = vehicle_capability
      end
    else
      vehicle_capability = vehicle_config_capability.vehicle_capability
    end
    if !vehicle_capability.blank?
      static_field :vehicle_capability, vehicle_capability.name
      hidden_field :vehicle_capability_id
    else
      collection_select :vehicle_capability_id, VehicleCapability.order(:name), :id, :name, include_blank: true
    end
    # collection_select :vehicle_capability_id, VehicleCapability.order(:name), :id, :name, include_blank: true

    text_field :kph
    text_field :timeout

    # check_box :confirmed
    collection_select :confirmed_by_id, User.all, :id, :github_username, include_blank: true

    text_area :notes
  end

  controller do
    
  end
end
