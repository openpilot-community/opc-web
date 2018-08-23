Trestle.resource(:modifications) do
  menu do
    item :modifications, icon: "fa fa-pencil", group: :other
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :name
    column :created_at, align: :center
    column :updated_at, align: :center
    # actions
  end
  form do |modification|
    tab :general do
      text_field :name
      select :vehicle_config_ids, modification.vehicle_configs.blank? ? [] : VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type).where.not(parent_id: nil).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level"), { label: "Vehicle Config(s)" }, { multiple: true, data: { tags: true } }
      editor :summary
      editor :description
      editor :instructions
    end
    tab :hardware_types do
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
              admin_link_to("Add Hardware Type", admin: :modification_hardware_types, action: :new, class: "btn btn-default btn-list-add", params: { modification_id: modification.blank? ? nil : modification.id })
            ]
          }
        ]
      }
      
      table modification.modification_hardware_types, admin: :modification_hardware_types do
        column :name
        column :hardware_item_names
      end
    end
  end
  # Customize the form fields shown on the new/edit views.
  #
  # form do |modification|
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
  #   params.require(:modification).permit(:name, ...)
  # end
end
