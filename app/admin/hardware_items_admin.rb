Trestle.resource(:hardware_items) do
  

  # Customize the table columns shown on the index view.
  #
  table do
    column :name, link: true
    # column :created_at, align: :center
    # actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |hardware_item|
    text_field :name
    text_field :alternate_name
    text_area :description
    collection_select :hardware_type_id, HardwareType.order(:name), :id, :name, include_blank: true, label: "Type"
    check_box :compatible_with_all_vehicles
    check_box :available_for_purchase
    text_field :purchase_url
    check_box :requires_assembly
    check_box :can_be_built
    text_area :notes
    text_field :image_url
    text_field :install_guide_url
    text_field :source_image_url

    sidebar do
      if hardware_item.image.attached?
        render inline: image_tag(hardware_item.image.service_url, class: "profile-image")
      end
    end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:hardware_item).permit(:name, ...)
  # end
end
