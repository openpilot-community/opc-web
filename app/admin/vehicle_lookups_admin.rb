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
    skip_before_action :authenticate_user!, :only => [:new, :create, :show, :refreshing_status]
    skip_before_action :require_edit_permissions!, :only => [:new, :create, :show]
    def new
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support", "/lookup")])
      
      set_meta_tags og: {
        title: "Request / Research Vehicle Portability | Openpilot Database",
        image: asset_url("/assets/opengraph-image.png"),
        type: "website"
      }
      set_meta_tags keywords: ['request','vehicle','portability','check','compatibility','help','openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility']
      set_meta_tags description: "Request or Research Portability of a Vehicle for Openpilot"
      super
    end

    def index
      if current_user.blank? || current_user.is_visitor?
        redirect_to '/vehicle_lookups/new'
      end
      super
    end

    def create_vc
      vc = VehicleConfig.find_by_ymm(self.instance.year,self.instance.vehicle_make.id,self.instance.vehicle_model.id)
      if vc.blank?
        vc = VehicleConfig.new(year: self.instance.year, year_end: self.instance.year, vehicle_make_id: self.instance.vehicle_make_id, vehicle_model_id: self.instance.vehicle_model_id)
        vc.save!
      else
        vc = vc.first
      end
      vc
    end

    def handle_create_failed
      
    end
    def create
      self.instance = admin.build_instance(permitted_params, params)
      if admin.save_instance(instance)
        # SAVED
        respond_to do |format|
          format.html do
            flash[:message] = flash_message("create.success", title: "Woohoo!", message: "You're on your way to learning more about what your vehicle can do...Please wait while we pull some additional details...".html_safe)
            vc = create_vc
            redirect_to vehicle_configs_admin_path(id: vc.id), turbolinks: false and return
          end
          format.json { render json: instance, status: :created, location: admin.instance_path(instance) }
          format.js
        end
      else
        # NOT SAVED
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
              
              instance.update_attributes({lookup_count: instance.lookup_count + 1})
              
              # byebug
              # self.instance = admin.find_instance({ :id => instance.id })
              
              vc = create_vc
              title = "You did it!"
              message = %(
                Now that you've started researching your vehicle... 
                Join the Comma Slack to chat with the community about getting your vehicle running openpilot.
              ).html_safe
              if vc.vehicle_config_status.name == "upstreamed"
                title = "Good news!"
                message = %(
                  There is some support for openpilot for this vehicle.
                ).html_safe
              end
              
              if vc.vehicle_config_status.name == "Researching"
                title = "Awesome!"
                message = %(
                  You're well on your way to learning more about openpilot.
                  At this time, it looks like we will need to add support for this vehicle if its possible.<br /
                  Maybe that 'we' be you?
                  Join us in the Comma Slack to help us win self driving cars together.
                ).html_safe
              end

              if vc.vehicle_config_status.name == "In Development"
                title = "Whoah!"
                message = %(
                  It looks like someone is currently working on a port for this vehicle.
                  That's exciting!
                  Checkout the "Code" tab to check the progress.
                ).html_safe
              end

              if vc.vehicle_config_status.name == "Community"
                title = "Nice!"
                message = %(
                  This is currently a community supported vehicle.
                  Join the Comma Slack to chat with the community about getting your vehicle running openpilot.
                ).html_safe
              end
              flash[:message] = flash_message("found.success", title: title, message: message)
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
