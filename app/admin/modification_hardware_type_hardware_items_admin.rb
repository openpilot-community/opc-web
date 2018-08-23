Trestle.resource(:modification_hardware_type_hardware_items) do
  # menu do
  #   item :modification_hardware_type_hardware_items, icon: "fa fa-star", group: :other
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  form(dialog:true) do |modification_hardware_type_hardware_item|
    tab :general do
      if modification_hardware_type_hardware_item.modification_hardware_type.blank?
        if params[:modification_hardware_type_id]
          modification_hardware_type = ModificationHardwareType.find(params[:modification_hardware_type_id])
          modification_hardware_type_hardware_item.modification_hardware_type = modification_hardware_type
        end
      else
        modification_hardware_type = modification_hardware_type_hardware_item.modification_hardware_type
      end
      if !modification_hardware_type.blank?
        static_field :modification, modification_hardware_type.modification.name
        static_field :modification_hardware_type, modification_hardware_type.name
        hidden_field :modification_hardware_type_id
      else
        collection_select :modification_hardware_type_id, ModificationHardwareTypeHardwareItem.order(:name), :id, :name, include_blank: true
      end
      collection_select :hardware_item_id, HardwareItem.order(:name), :id, :name, include_blank: true
    end
  end
  # Customize the form fields shown on the new/edit views.
  #
  # form do |modification_hardware_type_hardware_item|
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
  #   params.require(:modification_hardware_type_hardware_item).permit(:name, ...)
  # end
end
