Trestle.resource(:vehicle_models) do
  # menu do
  #   item :vehicle_models, icon: "fa fa-car", group: :vehicle_info, label: "Models"
  # end

  # VehicleMake.order(:name).each do |make|
  #   scope :"#{make.id}", -> { VehicleModel.includes(:vehicle_make).where(:vehicle_make => make).order("name") }
  # end
  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end
  controller do
    def index
      # byebug
      if !params['make'].blank?
        collection = VehicleModel.where(vehicle_make: VehicleMake.find(params['make'].to_i), status: 1).order(:name)
      end
      respond_to do |format|
        format.html
        format.json { render json: collection }
        format.js
      end
    end
    def get_by_make
      VehicleModel.where(:vehicle_make_id => params['vehicle_make_id']).to_json
    end
  end
  form(dialog: true) do |vehicle_model|
    tab :general do
      if vehicle_model.vehicle_make.blank?
        if params[:vehicle_make_id]
          vehicle_make = VehicleMake.find(params[:vehicle_make_id])
          vehicle_model.vehicle_make = vehicle_make
        end
      else
        vehicle_make = vehicle_model.vehicle_make
      end
      if !vehicle_make.blank?
        static_field :vehicle_make, vehicle_make.name
        hidden_field :vehicle_make_id
      else
        collection_select :vehicle_make_id, VehicleMake.order(:name), :id, :name, include_blank: true
      end
  
      text_field :name
      select :status, VehicleModel.statuses.map {|k, v| [k.humanize.capitalize, k]}
    end

    unless vehicle_model.new_record?
      tab :trims, badge: vehicle_model.vehicle_trims.blank? ? nil : vehicle_model.vehicle_trims.size do
        render "tab_toolbar", {
          :groups => [
            {
              :class => "actions",
              :items => [
                admin_link_to("Add Trim", admin: :vehicle_trims, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_model_id: vehicle_model.blank? ? nil : vehicle_model.id })
              ]
            }
          ]
        }
        
        table vehicle_model.vehicle_trims.blank? ? [] : vehicle_model.vehicle_trims.order('vehicle_trims.year'), admin: :vehicle_trims do
          column :name
          column :year
          column :has_driver_assist?
          column :sort_order
        end
      end
    end
  end
  search do |query|
    if query
      VehicleModel.where("name ILIKE ?", "%#{query}%")
    else
      VehicleModel.all
    end
  end

  routes do
    get :get_by_make, :path => "/get_by_make", :controller => :vehicle_models_admin
  end
  # Customize the form fields shown on the new/edit views.
  #
  
  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:vehicle_model).permit(:name, ...)
  # end
end
