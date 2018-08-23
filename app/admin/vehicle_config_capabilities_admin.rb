Trestle.resource(:vehicle_config_capabilities) do
  # menu do
  #   item :vehicle_config_capabilities, icon: "fa fa-star", group: :other
  # end

  form(dialog:true) do |vehicle_config_capability|
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
    collection_select :vehicle_capability_id, VehicleCapability.order(:name), :id, :name, include_blank: true


    text_field :kph
    text_field :timeout

    check_box :confirmed
    text_field :confirmed_by

    text_area :notes
  end

  controller do
    def create
      self.instance = admin.build_instance(permitted_params, params)
      if admin.save_instance(instance)
        respond_to do |format|
          format.html do
            flash[:message] = flash_message("create.success", title: "Success!", message: "The %{lowercase_model_name} was successfully created.")
            redirect_to_return_location(:create, instance, default: admin.instance_path(instance))
          end
          format.json { render json: instance, status: :created, location: admin.instance_path(instance) }
          format.js
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:error] = flash_message("create.failure", title: "Warning!", message: "Please correct the errors below.")
            render "new", status: :unprocessable_entity
          end
          format.json { render json: instance.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    def update
      admin.update_instance(instance, permitted_params, params)

      if admin.save_instance(instance)
        respond_to do |format|
          format.html do
            flash[:message] = flash_message("update.success", title: "Success!", message: "The %{lowercase_model_name} was successfully updated.")
            redirect_to_return_location(:update, instance, default: admin.instance_path(instance))
          end
          format.json { render json: instance, status: :ok }
          format.js
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:error] = flash_message("update.failure", title: "Warning!", message: "Please correct the errors below.")
            render "show", status: :unprocessable_entity
          end
          format.json { render json: instance.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end
  end
end
