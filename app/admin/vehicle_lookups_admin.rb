Trestle.resource(:vehicle_lookups) do
  menu do
    item :vehicle_lookups, icon: "fa fa-star", group: :admin
  end

  form do |vehicle_lookup|
    row do
      col(md: 6, class: "lookup-header") do
        image_tag(asset_url("compatibility-check-header@2x.png"))
      end
    end
    row do
      col(md: 6, class: "lookup-year") do
        select :year, (Time.zone.now.year + 1).downto(2006), prompt: "Year"
      end
    end
    row do
      col(md: 6) { collection_select :vehicle_make_id, VehicleMake.order(:name), :id, :name, prompt: "Make" }
    end
    row do
      col(md: 6) { collection_select :vehicle_model_id, [], :id, :name, prompt: "Model" }
    end
  end

  controller do
    include ActionView::Helpers::AssetUrlHelper
    skip_before_action :authenticate_user!, :only => [:new, :create,:show]
    skip_before_action :require_edit_permissions!, :only => [:new, :create, :show]

    def index
      if current_user.blank? || current_user.is_visitor?
        redirect_to '/vehicle_lookups/new'
      end
      super
    end

    def create
      self.instance = admin.build_instance(permitted_params, params)

      if admin.save_instance(instance)
        respond_to do |format|
          format.html do
            flash[:message] = flash_message("create.success", title: "Woohoo!", message: "You're on your way to learning more about what your vehicle can do...<br />Please wait while we pull some additional details...".html_safe)
            vc = VehicleConfig.find_by_ymm(instance.year,instance.vehicle_make.id,instance.vehicle_model.id)
            if vc.blank?
              vc = VehicleConfig.new(year: instance.year, year_end: instance.year, vehicle_make: instance.vehicle_make, vehicle_model: instance.vehicle_model)
              vc.save
            end
            redirect_to vehicle_configs_admin_path(id: vc.id), turbolinks: false and return
          end
          format.json { render json: instance, status: :created, location: admin.instance_path(instance) }
          format.js
        end
      else
        respond_to do |format|
          format.html do
            dupes = VehicleLookup.where(%(
                vehicle_lookups.year = :year AND 
                vehicle_lookups.vehicle_make_id = :vehicle_make AND 
                vehicle_lookups.vehicle_model_id = :vehicle_model
            ), {
              year: instance.year,
              vehicle_make: instance.vehicle_make_id,
              vehicle_model: instance.vehicle_model_id
            })

            if dupes.count == 1
              instance = dupes.first
              # vehicle_lookup.
              
              instance.lookup_count = instance.lookup_count + 1
              instance.save!

              # self.instance = admin.find_instance({ :id => instance.id })
              vc = VehicleConfig.find_by_ymm(instance.year,instance.vehicle_make.id,instance.vehicle_model.id)
              if vc.blank?
                vc = VehicleConfig.new(year: instance.year, year_end: instance.year, vehicle_make: instance.vehicle_make, vehicle_model: instance.vehicle_model)
                vc.save
              end

              # byebug
              flash[:message] = flash_message("found.success", title: "Woohoo!", message: "We found this vehicle in our system.".html_safe)
              redirect_to vehicle_configs_admin_path(id: vc.id), turbolinks: false and return
            else
              flash.now[:error] = flash_message("create.failure", title: "Warning!", message: "Please correct the errors below.")
              render "new", status: :unprocessable_entity
            end
          end

          format.json { render json: instance.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end
    def refreshing_status
      self.instance = admin.find_instance(params).root

      respond_to do |format|
        format.json { render json: instance, status: 200 }
      end
    end
  end
end
