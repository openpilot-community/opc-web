Trestle.resource(:guide_hardware_items) do
  # menu do
  #   item :guide_hardware_items, icon: "fa fa-star", group: :other
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  form(dialog: true) do |guide_hardware_item|
    is_new_guide = params['new'].present?
    is_edit_guide = params['edit'].present?
    is_from_url = params['from_url'].present?
    
    if guide_hardware_item.hardware_item.blank?
      if params[:hardware_item_id]
        hardware_item = HardwareItem.find(params[:hardware_item_id])
        guide_hardware_item.hardware_item = hardware_item
      end
    else
      hardware_item = guide_hardware_item.hardware_item
    end

    if is_new_guide
      vehicle_label = "Writing a new guide for the "
    elsif is_edit_guide
      vehicle_label = "Editing this guide for the "
    else
      vehicle_label = "Linking a guide to "
    end

    if hardware_item.present?
      static_field :hardware_item, hardware_item.name, label: vehicle_label
      hidden_field :hardware_item_id
    end

    if is_edit_guide
      render inline: content_tag(
        :div,
        "<h4>READ BEFORE PROCEEDING</h4> You are editing an existing guide.  This guide may not be specific to this piece of hardware.  Ensure it is a hardware specific guide before adding content that might pertain to it.".html_safe,
        class: "alert alert-warning",
          style: "display:block;"
      )
    end

    if is_from_url
      fields_for :guide, guide_hardware_item.guide || guide_hardware_item.build_guide do
        # Form helper methods now dispatch to the product.category form scope
        text_field :article_source_url
        # select :hardware_item_ids, HardwareItem.all.order(:name), {label: "Tag hardware in this guide"}, {prompt: "Choose an existing guide"}, { multiple: true, data: { tags: true } }
        hidden_field :user_id, :value => current_user.id
      end
    else
      if (is_new_guide || is_edit_guide)
        
        fields_for :guide, guide_hardware_item.guide || guide_hardware_item.build_guide do
          # Form helper methods now dispatch to the product.category form scope
          text_field :title
          # select :hardware_item_ids, HardwareItem.all.order(:name), { label: "Tag hardware in this guide" }, { multiple: true, data: { tags: true } }
          # select :vehicle_config_ids, VehicleConfig.includes(:vehicle_make, :vehicle_model, :hardware_item_type, :hardware_item_status, :repositories, :pull_requests, :hardware_item_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, hardware_item_types.difficulty_level"), { label: "Tag vehicles in this guide" }, { multiple: true, data: { tags: true } }
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
  # form do |guide_hardware_item|
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
  #   params.require(:guide_hardware_item).permit(:name, ...)
  # end
end
