Trestle.resource(:vehicle_config_hardware_items) do
  # menu do
  #   item :vehicle_config_hardware_items, icon: "fa fa-star", group: :other
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
  form(dialog: true) do |vehicle_config_hardware_item|
    is_new = params['new'].present?
    is_edit = params['edit'].present?
    
    if vehicle_config_hardware_item.vehicle_config.blank?
      if params[:vehicle_config_id]
        vehicle_config = VehicleConfig.find(params[:vehicle_config_id])
        vehicle_config_hardware_item.vehicle_config = vehicle_config
      end
    else
      vehicle_config = vehicle_config_hardware_item.vehicle_config
    end
    if is_new
      vehicle_label = "Writing a new harware document for the "
    elsif is_edit
      vehicle_label = "Editing hardware document for the "
    else
      vehicle_label = "Linking a hardware document to "
    end
    
    if vehicle_config.present?
      static_field :vehicle_config, vehicle_config.name, label: vehicle_label
      hidden_field :vehicle_config_id
    else
      collection_select(
        :vehicle_config_id, 
        VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :vehicle_config_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, vehicle_config_types.difficulty_level"),
        :id, 
        :name, 
        label: "Vehicle", 
        disabled: true, 
        include_blank: true
      )
    end

    if is_edit
      render inline: content_tag(
        :div,
        "<h4>READ BEFORE PROCEEDING</h4> You are editing an existing hardware item.  This hardware item may not be specific to this vehicle.  Ensure it is a vehicle specific hardware before adding content that might pertain to it.".html_safe,
        class: "alert alert-warning",
          style: "display:block;"
      )
    end

    if (is_new || is_edit)
      fields_for :hardware_item, vehicle_config_hardware_item.hardware_item || vehicle_config_hardware_item.build_hardware_item do
        # Form helper methods now dispatch to the product.category form scope
        text_field :name, label: "Name of hardware"
        text_area :description, { label: false, class: "simplemde-inline", placeholder: "Details about the hardware. (markdown format)" }
        text_field :source_image_url, { label: "Image URL" }
      end
    else
      collection_select :hardware_item_id, HardwareItem.order(:name), :id, :name, include_blank: true
    end
  end

end
