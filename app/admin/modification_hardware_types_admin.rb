Trestle.resource(:modification_hardware_types) do
  # menu do
  #   item :modification_hardware_types, icon: "fa fa-star", group: :other
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  form(dialog:true) do |modification_hardware_type|
    tab :general do
      if modification_hardware_type.modification.blank?
        if params[:modification_id]
          modification = Modification.find(params[:modification_id])
          modification_hardware_type.modification = modification
        end
      else
        modification = modification_hardware_type.modification
      end
      if !modification.blank?
        static_field :modification, modification.name
        hidden_field :modification_id
      else
        collection_select :modification_id, Modification.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :modification_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, vehicle_config_types.difficulty_level"), :id, :name, disabled: true, include_blank: true
      end
      collection_select :hardware_type_id, HardwareType.order(:name), :id, :name, include_blank: true
    end
    tab :hardware_items do
      render "tab_toolbar", {
        :groups => [
          # {
          #   :class => 'filters pull-left',
          #   :items => [
          #     link_to("Active (#{modification.active_count})", "?filter=active#!tab-models", class: params[:filter] == "active" ? "btn btn-default btn-list-add active" : "btn btn-default btn-list-add"),
          #     link_to("Inactive (#{modification.inactive_count})", "?filter=inactive#!tab-models", class: params[:filter] == "inactive" ? "btn btn-default btn-list-add active" : "btn btn-default btn-list-add")
          #   ]
          # },
          {
            :class => "actions pull-right",
            :items => [
              admin_link_to("Add Hardware Item", admin: :modification_hardware_type_hardware_items, action: :new, class: "btn btn-default btn-list-add", params: { modification_hardware_type_id: modification_hardware_type.blank? ? nil : modification_hardware_type.id })
            ]
          }
        ]
      }
      
      table modification_hardware_type.modification_hardware_type_hardware_items, admin: :modification_hardware_type_hardware_items do
        column :name
        column :hardware_item_names
      end
    end
end
  # Customize the form fields shown on the new/edit views.
  #
  # form do |modification_hardware_type|
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
  #   params.require(:modification_hardware_type).permit(:name, ...)
  # end
end
