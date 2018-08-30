Trestle.resource(:vehicle_configs) do

  menu do
    group :vehicles, priority: 100 do
      item :vehicle_configs, icon: "fa fa-car", group: :vehicles, label: "Research / Support"
    end
  end

  ########
  # SCOPES
  ########
  scope :all, -> { VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type).where(parent_id: nil).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level") }, default: true

  ########
  # SEARCH
  ########
  search do |query|
    if query
      VehicleConfig.where("title ILIKE ?", "%#{query}%")
    else
      VehicleConfig.all
    end
  end

  controller do
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, :only => [:show, :refreshing_status]
    include ActionView::Helpers::AssetUrlHelper
    def index
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support", "/vehicle_configs")])
      set_meta_tags og: {
        title: "Vehicle Research and Support | Openpilot Database",
        image: asset_url("/assets/opengraph-image.png"),
        type: "website"
      }
      set_meta_tags keywords: ['openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility']
      set_meta_tags description: "This is a master list of vehicles supported and being researched on for usage with openpilot software."
      super
      # breadcrumbs = Trestle::Breadcrumb::Trail.new(["Vehicle Search and Support"])
    end
    def create
      self.instance = admin.build_instance(permitted_params, params)

      if admin.save_instance(instance)
        respond_to do |format|
          format.html do
            flash[:message] = flash_message("create.success", title: "Success!", message: "The %{lowercase_model_name} was successfully created.")
            redirect_to_return_location(:create, instance, default: admin.instance_path(instance))
          end
          format.json { render json: instance, status: :created, location: admin.instance_path(instance) }
          format.js
        end
      else
        respond_to do |format|
          format.html do
            dupes = VehicleConfig.where(%(
              (
                vehicle_configs.year = :year AND 
                vehicle_configs.vehicle_make_id = :vehicle_make AND 
                vehicle_configs.vehicle_model_id = :vehicle_model AND
                vehicle_configs.vehicle_config_type_id = :config_type
              ) OR (
                vehicle_configs.year_end = :year AND 
                vehicle_configs.vehicle_make_id = :vehicle_make AND 
                vehicle_configs.vehicle_model_id = :vehicle_model AND
                vehicle_configs.vehicle_config_type_id = :config_type
              ) OR (
                vehicle_configs.year_end = :year AND 
                vehicle_configs.vehicle_make_id = :vehicle_make AND 
                vehicle_configs.vehicle_model_id = :vehicle_model AND
                vehicle_configs.vehicle_config_type_id = :config_type
              ) OR (
                vehicle_configs.year_end = :year_end AND 
                vehicle_configs.vehicle_make_id = :vehicle_make AND 
                vehicle_configs.vehicle_model_id = :vehicle_model AND
                vehicle_configs.vehicle_config_type_id = :config_type
              ) OR (
                ((:year) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
                vehicle_configs.vehicle_make_id = :vehicle_make AND 
                vehicle_configs.vehicle_model_id = :vehicle_model AND
                vehicle_configs.vehicle_config_type_id = :config_type
              ) OR (
                ((:year_end) BETWEEN vehicle_configs.year AND vehicle_configs.year_end) AND 
                vehicle_configs.vehicle_make_id = :vehicle_make AND 
                vehicle_configs.vehicle_model_id = :vehicle_model AND
                vehicle_configs.vehicle_config_type_id = :config_type
              )
            ), {
              year: instance.year,
              year_end: instance.year_end,
              vehicle_make: instance.vehicle_make_id,
              vehicle_model: instance.vehicle_model_id,
              config_type: instance.vehicle_config_type_id
            })

            if dupes.count == 1
              record = dupes.first
              self.instance = admin.find_instance({ :id => record.id })
              flash[:message] = flash_message("found.success", title: "Thank you, this configuration already exists.", message: "We found that configuration already in the database. Please refer to this configuration instead of creating a new one.".html_safe)
              redirect_to_return_location(:show, instance, default: admin.instance_path(instance))
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

    def show
      vehicle_config_root = admin.find_instance(params)
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support","/vehicle_configs")])
      set_meta_tags og: {
        title: "#{vehicle_config_root.name} | Openpilot Database",
        image: vehicle_config_root.image.attached? ? vehicle_config_root.image.service_url : asset_url("/assets/opengraph-image.png"),
        type: "website"
      }
      set_meta_tags keywords: ['openpilot','vehicle','support',vehicle_config_root.vehicle_make.name,vehicle_config_root.vehicle_model.name,vehicle_config_root.name,'of','vehicles','supported','compatible','compatibility']
      set_meta_tags description: "Research and support of comma openpilot for the #{vehicle_config_root.name}."
      super
    end

    def refreshing_status
      self.instance = admin.find_instance(params)

      respond_to do |format|
        format.json { render json: instance, status: 200 }
      end
    end

    def refresh_trims
      self.instance = admin.find_instance(params)
      vehicle_config_root = admin.find_instance(params)
      vehicle_config_root.refreshing = true
      vehicle_config_root.save!
      vehicle_config_root.delay.scrape_info
      flash[:message] = "Vehicle trims list is being refreshed... reload the browser to see results."
      redirect_to admin.path(:show, id: vehicle_config_root.id)
    end

    def fork
      vehicle_config_root = admin.find_instance(params)
      new_config = vehicle_config_root.fork_config
      veh_conf_type = VehicleConfigType.find(params[:config_type])
      new_config.parent = vehicle_config_root
      new_config.vehicle_config_type = veh_conf_type
      new_config.save!
      flash[:message] = "Vehicle has been forked."
      redirect_to admin.path(:show, id: new_config.id)
    end

    def quick_add
      self.instance = admin.find_instance(params)
      # byebug
      instance.vehicle_config_capabilities.new({
        vehicle_capability_id: params['vehicle_capability_id'],
        vehicle_config_type_id: params['vehicle_config_type_id']
      })
      instance.save!
      respond_to do |format|
        format.json { render json: instance, status: 200 }
      end
    end

    def quick_delete
      self.instance = admin.find_instance(params)
      instance.vehicle_config_capabilities.find_by({
        vehicle_capability_id: params[:vehicle_capability_id],
        vehicle_config_type_id: params[:vehicle_config_type_id]
      }).destroy()
      
      respond_to do |format|
        format.json { render json: instance, status: 200 }
      end
    end

    def clone
      vehicle_config = admin.find_instance(params)
      new_config = vehicle_config.copy_config
      new_config.save!
      flash[:message] = "Vehicle has been cloned."
      redirect_to admin.path(:show, id: new_config.id)
    end
  end

  routes do
    get :refresh_trims, :on => :member
    get :fork, :on => :member
    get :clone, :on => :member
    post :quick_add, :on => :member
    delete :quick_delete, :on => :member
    get :refreshing_status, :on => :member
  end

  table do |a|
    row do |vehicle|
      { class: "#{vehicle.vehicle_config_status.blank? ? nil : vehicle.vehicle_config_status.name.parameterize} #{vehicle.vehicle_config_type.blank? ? "unknown" : vehicle.vehicle_config_type.slug} vehicle-config" }
    end
    column :year_range_str, header: "Year(s)", sort: false, link: true
    column :vehicle_make, header: "Make",  sort: false, link: true do |vehicle_config|
      vehicle_config.vehicle_make.name
    end
    column :vehicle_model, header: "Make",  sort: false, link: true do |vehicle_config|
      vehicle_config.vehicle_model.name
    end
    column :trim_styles_count, header: "Trims", sort: false
    column :minimum_difficulty, header: "Min. Difficulty", sort: false do |vehicle_config|
      render "difficulty_label", vehicle_config: vehicle_config
    end
    column :status, header: "Status" do |vehicle_config|
      render "config_status", vehicle_config: vehicle_config
    end
  end

  ##########
  #  FORM  #
  ##########
  form do |vehicle_config|
    tab :general do
      if vehicle_config.parent.blank?
        row do
          col(sm: 3, class: "year-range") do
            row do
              col(sm: 6, class: "year-start") { select :year, 2010..(Time.zone.now.year + 2) }
              col(sm: 6, class: "year-end") { select :year_end, 2010..(Time.zone.now.year + 2), label: nil }
            end
          end
          col(sm: 4) { collection_select :vehicle_make_id, VehicleMake.order(:name), :id, :name, include_blank: true }
          col(sm: 5) { collection_select :vehicle_model_id, vehicle_config.vehicle_make.blank? ? [] : vehicle_config.vehicle_make.vehicle_models.order(:name), :id, :name, include_blank: true }
        end
      else
        static_field :name, "#{vehicle_config.name.blank? ? nil : vehicle_config.name}"

        hidden_field :year
        hidden_field :year_end
        hidden_field :vehicle_make_id
        hidden_field :vehicle_model_id
        hidden_field :vehicle_trim_id
      end

      if vehicle_config.persisted?
        collection_select :vehicle_make_package_id, VehicleMakePackage.where(vehicle_make: vehicle_config.vehicle_make).order(:name), :id, :name, include_blank: true, label: "Required Factory Installed Option"
      end
    end

    unless vehicle_config.new_record? || vehicle_config.vehicle_config_type.blank?
      tab :trim_styles, badge: vehicle_config.refreshing ? "<span class=\"fa fa-spinner fa-spin\"></span>".html_safe : vehicle_config.trim_styles_count do
        if vehicle_config.refreshing
          render inline: content_tag(:div, "<span class=\"fa fa-spinner fa-spin\"></span><span class='loading-message'>We're refreshing the trim styles...</span>".html_safe, class: "alert alert-warning alert-loading-trims")
        else
          render "tab_toolbar", {
          :groups => [
            {
              :class => "actions",
              :items => [
                link_to("<span class=\"fa fa-refresh\"></span> Scan For Trims".html_safe, admin.path(:refresh_trims, id: instance.id), method: :get, class: "btn btn-default btn-block")
              ]
            }
          ]
        }

        if vehicle_config.trim_styles.blank?
          render inline: content_tag(:div, "We could not find any trims for this year, make and model.", class: "alert alert-warning")
        else
          table vehicle_config.trim_styles.blank? ? [] : vehicle_config.trim_styles, admin: :vehicle_trim_styles do
              # column :id
              column :year
              column :trim_name, header: "Trim"
              column :name_for_list, header: "Style"
              column :driver_assist_inclusion, header: "ACC/LKAS" do |trim_style|
                if trim_style.driver_assist_inclusion == "standard"
                  "<span class=\"label label-success\">#{trim_style.driver_assist_inclusion}</span>".html_safe
                elsif trim_style.driver_assist_inclusion == "option"
                  "<span class=\"label label-info\">#{trim_style.driver_assist_inclusion}</span>".html_safe
                else
                  "<span class=\"label label-danger\">Not Available</span>".html_safe
                end
              end
              column :price
              # column :driver_assisted_style_names, header: "ACC/LKAS Trim(s) Option or Standard"
              # column :has_driver_assist?, header: "Available Driver Assist", align: :center
              # column :speed
              # column :timeout_friendly, :header => "Timeout"
              # column :confirmed
            end
          end
        end
      end
      tab :capabilities do
        config_types = VehicleConfigType.order(:difficulty_level)
        vehicle_capabilities_common = VehicleCapability.where("vehicle_capabilities.vehicle_config_count > 5").order(:name)
        vehicle_capabilities_uncommon = VehicleCapability.where.not(id: vehicle_capabilities_common.map(&:id)).order(:name)
        vccs = vehicle_config.vehicle_config_capabilities
        # vct_factory = VehicleConfigType.find_by(name: 'Factory')
        # vct_standard = VehicleConfigType.find_by(name: 'Standard')
        # vct_basic = VehicleConfigType.find_by(name: 'Basic')
        # vct_advanced = VehicleConfigType.find_by(name: 'Advanced')
        table vehicle_capabilities_common, admin: :vehicle_capabilities_admin do
          column :name, header: "Common Capabilities"
          config_types.each do |type|
          column type.name.parameterize.to_sym, 
            class: "type-#{type.name.parameterize}", 
            header: %(
              #{type.name}
              <span data-toggle='tooltip' data-container='body' title='#{type.description}' class='fa fa-info'></span>
            ).html_safe do |c|
              if (vcc = vccs.find_by(vehicle_config_type: type, vehicle_capability: c))
                admin_link_to("<span class=\"fa fa-check\"></span>".html_safe, admin: :vehicle_config_capabilities, action: :show, class: "btn btn-success btn-list-edit #{c.value_type.present? ? "type-" + c.value_type.parameterize() : "type-quick-delete"}", params: { 
                  id: vcc.id
                })
              else
                admin_link_to("<span class=\"fa fa-plus\"></span>".html_safe, admin: :vehicle_config_capabilities, action: :new, class: "btn btn-default btn-list-add #{c.value_type.present? ? "type-" + c.value_type.parameterize() : "type-quick-add"}", params: { 
                  vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id,
                  vehicle_config_type_id: type.id,
                  vehicle_capability_id: c.id
                })
              end
            end
          end
        end if vehicle_capabilities_common.present?
          
          table vehicle_capabilities_uncommon, admin: :vehicle_capabilities_admin do
            column :name, header: "Common Capabilities"
            config_types.each do |type|
              column type.name.parameterize.to_sym, 
              class: "type-#{type.name.parameterize}", 
              header: %(
                #{type.name}
                <span data-toggle='tooltip' data-container='body' title='#{type.description}' class='fa fa-info'></span>
              ).html_safe do |c|
              if (vcc = vccs.find_by(vehicle_config_type: type, vehicle_capability: c))
                admin_link_to("<span class=\"fa fa-check\"></span>".html_safe, admin: :vehicle_config_capabilities, action: :show, class: "btn btn-success btn-list-edit #{c.value_type.present? ? "type-" + c.value_type.parameterize() : "type-quick-delete"}", params: { 
                  id: vcc.id
                })
              else
                admin_link_to("<span class=\"fa fa-plus\"></span>".html_safe, admin: :vehicle_config_capabilities, action: :new, class: "btn btn-default btn-list-add #{c.value_type.present? ? "type-" + c.value_type.parameterize() : "type-quick-add"}", params: { 
                  vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id,
                  vehicle_config_type_id: type.id,
                  vehicle_capability_id: c.id
                })
              end
            end
          end
        end
      end
      tab :modifications, badge: vehicle_config.vehicle_config_modifications.blank? ? nil : vehicle_config.vehicle_config_modifications.size do
        render "tab_toolbar", {
          :groups => [
            {
              :class => "actions",
              :items => [
                admin_link_to("Add Modification", admin: :vehicle_config_modifications, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id })
              ]
            }
          ]
        }
        
        table vehicle_config.vehicle_config_modifications.includes(:modification).order('modifications.name'), admin: :vehicle_config_modifications do
          column :modification, dialog: true
          column :hardware_item_names
        end
      end

      tab :code, badge: vehicle_config.vehicle_config_repositories.blank? ? nil : vehicle_config.vehicle_config_repositories.size do
        render "tab_toolbar", {
          :groups => [
            {
              :class => "actions",
              :items => [
                admin_link_to("<span class=\"fa fa-plus\"></span> Repository".html_safe, admin: :vehicle_config_repositories, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id }),
                admin_link_to("<span class=\"fa fa-plus\"></span> Pull Request".html_safe, admin: :vehicle_config_pull_requests, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id })
              ]
            }
          ]
        }
        collection_select :vehicle_config_status_id, VehicleConfigStatus.order(:name), :id, :name, include_blank: true, label: "Status of the codebase"

        table vehicle_config.vehicle_config_repositories, admin: :vehicle_config_repositories do
          column :name, header: "Repositories" do |vcr|
            link_to vcr.repository.url, target: "_blank" do
              "#{image_tag(vcr.repository.owner_avatar_url, width: "20")} #{vcr.repository.full_name}".html_safe
            end
          end
          column :repository_branch
        end

        table vehicle_config.vehicle_config_pull_requests, admin: :pull_requests do
            column :name, header: "Pull Requests" do |vcr|
              link_to vcr.pull_request.html_url, target: "_blank" do
                vcr.pull_request.name
              end
            end
            column :status do |vcr|
              vcr.pull_request.state
            end
            column :user do |vcr|
              vcr.pull_request.user
            end

            column :body do |vcr|
              vcr.pull_request.body
            end
          end
      end

      #####
      # CODE TAB
      #####
      tab :videos, badge: vehicle_config.vehicle_config_videos.blank? ? nil : vehicle_config.vehicle_config_videos.size do
        render "tab_toolbar", {
          :groups => [
            {
              :class => "actions",
              :items => [
                admin_link_to("<span class=\"fa fa-plus\"></span> Video".html_safe, admin: :vehicle_config_videos, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id }),
              ]
            }
          ]
        }
        table vehicle_config.vehicle_config_videos, admin: :vehicle_config_videos do
          column :thumbnail do |vehicle_config_video|
            image_tag(vehicle_config_video.thumbnail_url, width: '150')
          end
          column :name
          column :author
        end
      end
      
      tab :history do
        table vehicle_config.versions, admin: :versions do
          # column :user
          column :changeset do |version|
            render "changeset", changeset: version.changeset
          end
          column :author do |version|
            scope = User.where(id: version.whodunnit)
            if !scope.blank? 
              scope.first
            end
          end
          column :created_at
        end
      end

      sidebar do
        make = vehicle_config.vehicle_make
        slack_channel = make.slack_channel
        # byebug
        if slack_channel.present?
          render inline: link_to("<span class=\"fa fa-slack\"></span> #{slack_channel}".html_safe,"slack://channel?team=comma&id=#{slack_channel}", class: "btn btn-slack btn-block")
        else
          render inline: link_to("<span class=\"fa fa-slack\"></span> comma".html_safe,"slack://channel?team=comma", class: "btn btn-slack btn-block")
        end
        if vehicle_config.image.attached?
          render inline: image_tag(vehicle_config.image.service_url, class: "profile-image")
          render inline: content_tag(:div, nil, {style: "margin-top:10px;"})
        end
        if !vehicle_config.vehicle_config_videos.blank?
          render inline: vehicle_config.vehicle_config_videos.first.video.html.html_safe
          render inline: content_tag(:div, nil, {style: "margin-top:10px;"})
        end
        # render "fork_links", :instance => vehicle_config
        
        # collection_select :parent_id, VehicleConfig.where.not(id: vehicle_config.id).includes(:vehicle_make,:vehicle_model).where(:vehicle_make => vehicle_config.vehicle_make.blank? ? nil : vehicle_config.vehicle_make,:vehicle_model => vehicle_config.vehicle_model.blank? ? nil : vehicle_config.vehicle_model).where("parent_id IS NULL").order("vehicle_models.name, year"), :id, :name, include_blank: true, label: "Associate to new parent"
      end
    end
    
  end
  
end
