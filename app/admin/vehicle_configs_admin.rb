Trestle.resource(:vehicle_configs) do

  menu do
  #   byebug
    group :vehicles, priority: :first do
      item :vehicle_configs, "/research", icon: "fa fa-book-open", group: :vehicles, label: "Research / Support", priority: :first
    end
    group :vehicles_by_make do
      item :top_vehicle_configs, '/vehicle_configs?order=desc&sort=cached_votes_score', icon: "fa fa-star", group: :vehicles, label: "Top Voted Vehicles", priority: 2
      VehicleMake.with_configs.each do |make|
        item make.name.parameterize.to_sym, "#{Rails.application.routes.url_helpers.research_make_url(q: make.name.parameterize.downcase)}", icon: "fa fa-chevron-right"
      end
    end
  end

  ########
  # SCOPES
  ########
  scope :all, -> { VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level") }, default: true

  ########
  # SEARCH
  ########
  search do |query|
    if query
      query = query.titleize
      VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).where("vehicle_makes.name ILIKE :query OR vehicle_models.name ILIKE :query", { query: "%#{query}%" }).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level")
    else
      VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level")
    end
  end

  controller do
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, :only => [:show, :refreshing_status, :vote]
    include ActionView::Helpers::AssetUrlHelper
    def index
      if params['q']
        page_title = "#{params['q']} | Vehicle Research & Support Tracker"
      else
        page_title = "Vehicle Research & Support Tracker"
      end
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("#{page_title}", "/researching")])

      set_meta_tags(
        og: {
          title: "#{page_title} | Openpilot Database",
          image: asset_url("/assets/og/tracker.png"),
          url: Rails.application.routes.url_helpers.research_url,
          type: "website"
        },
        keywords: ['openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility'],
        description: "This is a master list of vehicles supported and being researched for usage with openpilot software.",
        canonical: Rails.application.routes.url_helpers.research_url,
        image_src: asset_url("/assets/og/tracker.png")
      )
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
      vehicle_config = admin.find_instance(params)
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support","/vehicle_configs")])
      imgurl = vehicle_config.image.attached? ? vehicle_config.image.service_url : asset_url("/assets/og/tracker.png")
      
      set_meta_tags(
        og: {
          title: "#{vehicle_config.name} | Openpilot Database",
          image: imgurl,
          url: Rails.application.routes.url_helpers.research_show_url(id: vehicle_config.id),
          type: "website"
        },
        keywords: ['openpilot','vehicle','support',vehicle_config.vehicle_make.name, vehicle_config.vehicle_model.name,vehicle_config.name,'of','vehicles','supported','compatible','compatibility'],
        description: "Research and support of comma openpilot for the #{vehicle_config.name}.",
        canonical: Rails.application.routes.url_helpers.research_show_url(id: vehicle_config.id),
        image_src: imgurl
      )
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
      vehicle_config = admin.find_instance(params)
      vehicle_config.update_attributes(refreshing: true)
      # vehicle_config.refreshing = true
      # vehicle_config.save!
      ScrapeCarImageWorker.perform_async(vehicle_config.id)
      ScrapeCarsWorker.perform_async(vehicle_config.id)
      flash[:message] = "Vehicle trims list is being refreshed... reload the browser to see results."
      redirect_to admin.path(:show, id: vehicle_config.id)
    end
    
    def vote
      self.instance = admin.find_instance(params)

      if params['vote'] == "up"
        if (current_or_guest_user.voted_up_on? instance)
          instance.unvote_by current_or_guest_user
        else
          instance.upvote_by current_or_guest_user
        end
      end
      if params['vote'] == 'down'
        if (current_or_guest_user.voted_down_on? instance)
          instance.unvote_by current_or_guest_user
        else
          instance.downvote_by current_or_guest_user
        end
      end
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render json: instance, status: 200 }
      end
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
  end

  routes do
    get :refresh_trims, :on => :member
    get :fork, :on => :member
    get :clone, :on => :member
    post :quick_add, :on => :member
    get :vote, :on => :member
    delete :quick_delete, :on => :member
    get :refreshing_status, :on => :member
  end

  table do |a|
    row do |vehicle|
      { data: { url: "/research/#{vehicle.id}#!tab-trim_styles"}, class: "#{vehicle.vehicle_config_status.blank? ? nil : vehicle.vehicle_config_status.name.parameterize} #{vehicle.vehicle_config_type.blank? ? "unknown" : vehicle.vehicle_config_type.slug} vehicle-config" }
    end
    column :votes, align: :center, class: "votes-column" do |instance|
      content_tag(:div, class: "vote-action #{current_or_guest_user.voted_down_on?(instance) ? "downvoted" : nil} #{current_or_guest_user.voted_up_on?(instance) ? 'upvoted' : nil} #{current_or_guest_user.voted_for?(instance) ? "voted" : nil}") do
        %(
        #{link_to('<span class=\'fa fa-arrow-up\'></span>'.html_safe, vote_vehicle_configs_admin_url(instance.id, :format=> :json, params: { vote: 'up' }), remote: true, id: "vote_up_#{instance.id}", class: "vote-up ")}
        #{content_tag :span, instance.cached_votes_score, class: "badge badge-vote-count"}
        #{link_to('<span class=\'fa fa-arrow-down\'></span>'.html_safe, vote_vehicle_configs_admin_url(instance.id, :format=> :json, params: { vote: 'down' }), remote: true, id: "vote_down_#{instance.id}", class: "vote-down ")}
        ).html_safe
      end.html_safe
    end
    column :image, class: "image-column" do |vehicle_config|
      if vehicle_config.image.attached?
        image_tag(vehicle_config.image.service_url)
      end
    end
    column :vehicle, class: "details-column" do |vehicle_config|
      render "vehicle_config_details", instance: vehicle_config
    end
    # column :trim_styles_count, header: "Trims", sort: false
    actions
  end

  ##########
  #  FORM  #
  ##########
  form do |vehicle_config|
    tab :general do
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
    
      if vehicle_config.persisted?
        collection_select :vehicle_make_package_id, VehicleMakePackage.where(vehicle_make: vehicle_config.vehicle_make).order(:name), :id, :name, include_blank: true, label: "Required Factory Installed Option"
      end
    end

    unless vehicle_config.new_record?
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

        collection_select :vehicle_config_type_id, vehicle_config.vehicle_config_type.blank? ? [] : VehicleConfigType.order(:name), :id, :name, include_blank: true, label: "Min. Difficulty"
        slack_channel = make.slack_channel
        # byebug
        if slack_channel.present?
          render inline: link_to("<span class=\"fa fa-slack\"></span> #{slack_channel}".html_safe,"slack://channel?team=comma&id=#{slack_channel}", class: "btn btn-slack btn-block")
        else
          render inline: link_to("<span class=\"fa fa-slack\"></span> comma".html_safe,"slack://channel?team=comma", class: "btn btn-slack btn-block")
        end
        render inline: content_tag(:div, nil, {style: "margin-top:10px;"})
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
