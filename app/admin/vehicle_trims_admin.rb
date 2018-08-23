Trestle.resource(:vehicle_trims) do
  # menu do
  #   item :vehicle_trims, icon: "fa fa-car", group: :vehicle_info, label: "Trims"
  # end

  VehicleModel.order(:name).each do |model|
    scope :"#{model.id}", -> { VehicleTrim.includes(:vehicle_model).where(:vehicle_model => model).order("name") }
  end
  # Customize the table columns shown on the index view.
  #
  table do
    column :make_name, header: "Make", sort: false
    column :name_for_list, link: true, header: "Trim", sort: false
    # column :created_at, align: :center
    actions
  end

  search do |query|
    if query
      VehicleTrim.where("name ILIKE ?", "%#{query}%")
    else
      VehicleTrim.all
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form(dialog: true) do |vehicle_trim|
    tab :general do
      if vehicle_trim.vehicle_model.blank?
        if params[:vehicle_model_id]
          vehicle_model = VehicleModel.find(params[:vehicle_model_id])
          vehicle_trim.vehicle_model = vehicle_model
        end
      else
        vehicle_model = vehicle_trim.vehicle_model
      end
      if !vehicle_model.blank?
        static_field :vehicle_make_model,"#{vehicle_model.vehicle_make.name} #{vehicle_model.name}"
        hidden_field :vehicle_model_id
      else
        collection_select :vehicle_model_id, VehicleModel.where(:vehicle_make => vehicle_model.vehicle_make).order(:name), :id, :name, include_blank: true
      end
      # collection_select :vehicle_model_id, VehicleModel.order(:name), :id, :name_for_select, include_blank: true
      text_field :name, label: "Name of Trim", placeholder: "i.e. Touring, EX-L, etc."
      select :year, 2010..(Time.zone.now.year + 2)
      text_field :sort_order
      # row do
      #   col(xs: 6) { datetime_field :updated_at }
      #   col(xs: 6) { datetime_field :created_at }
      # end
    end
  end

  controller do
    def quick_add
      vehicle_config_root = admin.find_instance(params).root
      new_config = vehicle_config_root.fork_config
      veh_conf_type = VehicleConfigType.find(params[:config_type])
      new_config.parent = vehicle_config_root
      new_config.vehicle_config_type = veh_conf_type
      new_config.save
      flash[:message] = "Vehicle has been forked."
      redirect_to admin.path(:show, id: new_config.id)
    end
  end
  routes do
    post :quick_add
  end
  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:vehicle_trim).permit(:name, ...)
  # end
end
