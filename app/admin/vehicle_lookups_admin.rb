Trestle.resource(:vehicle_lookups) do

  form do |vehicle_lookup|
    row do
      col(md: 6, class: "lookup-header") do
        image_tag(asset_url("compatibility-check-header@2x.png"))
      end
    end
    row do
      col(md: 6, class: "lookup-year") do
        select :year, (Time.zone.now.year + 1).downto(2012), prompt: "Year"
      end
    end
    row do
      col(md: 6) { collection_select :vehicle_make_id, VehicleMake.where(status: 1).order(:name), :id, :name, prompt: "Make" }
    end
    row do
      col(md: 6) { collection_select :vehicle_model_id, [], :id, :name, prompt: "Model" }
    end
    row do
      col(md: 6, class: "lookup-header") do
        content_tag(:div, "Note: Vehicles older than 2012 are unlikely to have the hardware required to be plug-and-play with Openpilot.<br />If you're interested in adding functionality to a car older than 2012, visit the #old_cars channel in the Comma Slack.".html_safe, class: "alert alert-default", style: "font-size:12px; margin-bottom:0;")
      end
    end
  end
  controller do
    include ActionView::Helpers::AssetUrlHelper
    skip_before_action :authenticate_user!, :only => [:new, :create, :show, :refreshing_status]
    skip_before_action :require_edit_permissions!, :only => [:new, :create, :show]
    def new
      if params[:garage]
        session[:add_to_garage] = true
      end
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support", "/lookup")])
      
      set_meta_tags og: {
        title: "Request / Research Vehicle Portability | Openpilot Community",
        image: asset_url("/assets/compatibility-check-header.png"),
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
      @vc = VehicleConfig.find_by_ymm(self.instance.year,self.instance.vehicle_make.id,self.instance.vehicle_model.id)
      if @vc.blank?
        @vc = VehicleConfig.new(year: self.instance.year, year_end: self.instance.year, vehicle_make_id: self.instance.vehicle_make_id, vehicle_model_id: self.instance.vehicle_model_id)
        @vc.save!
      else
        @vc = @vc.first
      end
    end

    def finish_and_redirect
      title = "You did it!"
      message = %(
        Now that you've started researching your vehicle... 
        Join the Comma Slack to chat with the community about getting your vehicle running openpilot.
      ).html_safe
      if @vc.vehicle_config_status.present?
        if @vc.vehicle_config_status.name == "upstreamed"
          title = "Good news!"
          message = %(
            There is some support for openpilot for this vehicle.
          ).html_safe
        end
        
        if @vc.vehicle_config_status.name == "Researching"
          title = "Awesome!"
          message = %(
            You're well on your way to learning more about openpilot.
            At this time, it looks like we will need to add support for this vehicle if its possible.<br /
            Maybe that 'we' be you?
            Join us in the Comma Slack to help us win self driving cars together.
          ).html_safe
        end

        if @vc.vehicle_config_status.name == "In Development"
          title = "Whoah!"
          message = %(
            It looks like someone is currently working on a port for this vehicle.
            That's exciting!
            Checkout the "Code" tab to check the progress.
          ).html_safe
        end

        if @vc.vehicle_config_status.name == "Community"
          title = "Nice!"
          message = %(
            This is currently a community supported vehicle.
            Join the Comma Slack to chat with the community about getting your vehicle running openpilot.
          ).html_safe
        end
      end
      flash[:message] = flash_message("found.success", title: title, message: message)
      redirect_to vehicle_configs_admin_path(id: @vc.id), turbolinks: false, anchor: "!tab-trim_styles", :status => 303 and return
    end

    def set_vehicle_config_and_scrape
      create_vc
      
      if current_user.present? && session[:add_to_garage]
        byebug
        new_user_vehicle = UserVehicle.find_or_initialize_by(user_id: current_user.id, vehicle_config_id: @vc.id)

        new_user_vehicle.save
      end
      session[:add_to_garage] = false
      ScrapeCarsWorker.perform_async(@vc.id)
    end

    def create
      self.instance = admin.build_instance(admin.permitted_params(params), params)

      if admin.save_instance(instance)
        # SAVED
        respond_to do |format|
          format.html do
            set_vehicle_config_and_scrape
            finish_and_redirect
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
              
              set_vehicle_config_and_scrape
              
              finish_and_redirect
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
