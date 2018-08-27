Trestle.resource(:vehicle_configs) do
  
  menu do
    item :vehicle_configs, icon: "fa fa-car", group: :vehicles, label: "Research / Support", priority: :first
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
    def show
      # self.instance = admin.find_instance(params)
      vehicle_config_root = admin.find_instance(params).root
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("#{vehicle_config_root.name}","/vehicle_configs/#{vehicle_config_root.slug}")])
      set_meta_tags og: {
        title: "#{vehicle_config_root.name} | Openpilot Database",
        image: asset_url("/assets/opengraph-image.png"),
        type: "website"
      }
      set_meta_tags keywords: ['openpilot','vehicle','support',vehicle_config_root.vehicle_make.name,vehicle_config_root.vehicle_model.name,vehicle_config_root.name,'of','vehicles','supported','compatible','compatibility']
      set_meta_tags description: "Research and support of comma openpilot for the #{vehicle_config_root.name}."
      super
    end
    def refresh_trims
      vehicle_config_root = admin.find_instance(params).root
      vehicle_config_root.scrape_info
      flash[:message] = "Vehicle trim_styles list has been reloaded."
      redirect_to admin.path(:show, id: vehicle_config_root.id)
    end

    def fork
      vehicle_config_root = admin.find_instance(params).root
      new_config = vehicle_config_root.fork_config
      veh_conf_type = VehicleConfigType.find(params[:config_type])
      new_config.parent = vehicle_config_root
      new_config.vehicle_config_type = veh_conf_type
      new_config.save
      flash[:message] = "Vehicle has been forked."
      redirect_to admin.path(:show, id: new_config.id)
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

  #####
  # F O R M
  #####
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
          # col(sm: 5) do
          #   select :vehicle_trim_ids, (vehicle_config.vehicle_model.blank? ? [] : VehicleTrim.where(:vehicle_model => vehicle_config.vehicle_model.id).order(:name)), { label: "Trim(s)" }, { multiple: true, data: { tags: true } }
          #   # tag_select :vehicle_config_trim_styles
          # end
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
      tab :trim_styles, badge: vehicle_config.trim_styles_count do
        render "tab_toolbar", {
          :groups => [
            {
              :class => "actions",
              :items => [
                link_to("Scan For Trims", admin.path(:refresh_trims, id: instance.root.id), method: :get, class: "btn btn-default btn-block")
              ]
            }
          ]
        }
        
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
      tab :capabilities, badge: vehicle_config.vehicle_config_capabilities.blank? ? nil : vehicle_config.vehicle_config_capabilities.size do
        render "tab_toolbar", {
          :groups => [
            {
              :class => 'filters pull-left',
              :items => [
                content_tag(:h4, "#{vehicle_config.vehicle_config_type.name} Capabilities & Limits", class: [])
              ]
            },
            {
              :class => "actions",
              :items => [
                admin_link_to("Add Capability", admin: :vehicle_config_capabilities, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id })
              ]
            }
          ]
        }
        
        table vehicle_config.vehicle_config_capabilities.blank? ? [] : vehicle_config.vehicle_config_capabilities, admin: :vehicle_config_capabilities do
          column :name

          column :timeout_friendly, header: "Timeout"
          
          column :speed do |capability|
            if capability.mph.present?
              "#{capability.mph} mph (#{capability.kph} kph)"
            end
          end
          
          # column :confirmed
          column :confirmed_by
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
      # tab :children, badge: vehicle_config.forks.blank? ? nil : vehicle_config.forks.size do
      #   # render "tab_toolbar", {
      #   #   :groups => [
      #   #     {
      #   #       :class => "actions",
      #   #       :items => [
      #   #         admin_link_to("Add Capability", admin: :vehicle_config_capabilities, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_config_id: vehicle_config.blank? ? nil : vehicle_config.id })
      #   #       ]
      #   #     }
      #   #   ]
      #   # }
        
      #   table vehicle_config.forks.blank? ? [] : vehicle_config.forks.order(:id), admin: :vehicle_configs do
      #     column :name
      #     actions
      #   end
      # end
      #####
      # CODE TAB
      #####
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
        render "fork_links", :instance => vehicle_config
        concat(
          link_to(
            "<span class=\"fa fa-copy\"></span> Duplicate Entire Config".html_safe, 
            admin.path(:clone, id: vehicle_config.blank? ? nil : vehicle_config.root.id), 
            method: :get, 
            class: "btn btn-default btn-block", 
            confirm: 'This will copy the Factory config and all of its sub-configs to an entirely new vehicle config.\nAre you sure this is what you want to do?'
          )
        )
        # collection_select :parent_id, VehicleConfig.where.not(id: vehicle_config.id).includes(:vehicle_make,:vehicle_model).where(:vehicle_make => vehicle_config.vehicle_make.blank? ? nil : vehicle_config.vehicle_make,:vehicle_model => vehicle_config.vehicle_model.blank? ? nil : vehicle_config.vehicle_model).where("parent_id IS NULL").order("vehicle_models.name, year"), :id, :name, include_blank: true, label: "Associate to new parent"
      end
    end
    
  end
  
end
