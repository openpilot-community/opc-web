Trestle.resource(:vehicle_config_guides) do
  # menu do
  #   item :vehicle_config_guides, icon: "fa fa-star", group: :other
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  form(dialog: true) do |vehicle_config_guide|
    is_new_guide = params['new'].present?
    is_edit_guide = params['edit'].present?
    is_from_url = params['from_url'].present?
    if vehicle_config_guide.vehicle_config.blank?
      if params[:vehicle_config_id]
        vehicle_config = VehicleConfig.find(params[:vehicle_config_id])
        vehicle_config_guide.vehicle_config = vehicle_config
      end
    else
      vehicle_config = vehicle_config_guide.vehicle_config
    end
    if is_new_guide
      vehicle_label = "Writing a new guide for the "
    elsif is_edit_guide
      vehicle_label = "Editing this guide for the "
    else
      vehicle_label = "Linking a guide to "
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
        label: "Difficulty Tier", 
        disabled: true, 
        include_blank: true
      )
    end

    collection_select :vehicle_config_type_id, VehicleConfigType.where.not(difficulty_level: 0).order(:difficulty_level), :id, :name, prompt: "Any", label: "Difficulty Tier"
    
    if is_edit_guide
      render inline: content_tag(
        :div,
        "<h4>READ BEFORE PROCEEDING</h4> You are editing an existing guide.  This guide may not be specific to this vehicle.  Ensure it is a vehicle specific guide before adding content that might pertain to it.".html_safe,
        class: "alert alert-warning",
          style: "display:block;"
      )
    end

    if is_from_url
      fields_for :guide, vehicle_config_guide.guide || vehicle_config_guide.build_guide do
        # Form helper methods now dispatch to the product.category form scope
        text_field :article_source_url
        # select :hardware_item_ids, HardwareItem.all.order(:name), {label: "Tag hardware in this guide"}, {prompt: "Choose an existing guide"}, { multiple: true, data: { tags: true } }
        
        hidden_field :user_id, :value => current_user.id
      end
    else
      if (is_new_guide || is_edit_guide)
        
        fields_for :guide, vehicle_config_guide.guide || vehicle_config_guide.build_guide do
          # Form helper methods now dispatch to the product.category form scope
          text_field :title
          select :hardware_item_ids, HardwareItem.all.order(:name), { label: "Tag hardware in this guide" }, { multiple: true, data: { tags: true } }
          select :vehicle_config_ids, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level"), { label: "Tag vehicles in this guide" }, { multiple: true, data: { tags: true } }
          editor :markdown, { label: "" }
          text_field :author_name
          hidden_field :user_id, :value => current_user.id
          text_area :exerpt
        end
      else
        collection_select :guide_id, Guide.order(:title), :id, :title, include_blank: true
      end
    end
  end
  # Customize the form fields shown on the new/edit views.
  #
  # form do |vehicle_config_guide|
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
  #   params.require(:vehicle_config_guide).permit(:name, ...)
  # end
end
