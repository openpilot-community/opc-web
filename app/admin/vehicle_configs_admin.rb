Trestle.resource(:vehicle_configs, path: "/vehicles") do
  to_param do |instance|
    if instance.slug.present?
      instance.slug
    else
      instance.id
    end
  end
  find_instance do |params|
    VehicleConfig.friendly.find(params[:id])
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
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("#{page_title}", "/vehicles")])

      set_meta_tags(
        og: {
          title: "#{page_title} | Openpilot Database",
          image: asset_url("/assets/og/tracker.png"),
          url: File.join(Rails.application.routes.url_helpers.root_url,admin.path),
          type: "website"
        },
        keywords: ['openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility'],
        description: "This is a master list of vehicles supported and being researched for usage with openpilot software.",
        canonical: File.join(Rails.application.routes.url_helpers.root_url,admin.path),
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
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support","/vehicles")])
      imgurl = vehicle_config.image.attached? ? vehicle_config.image.service_url : asset_url("/assets/og/tracker.png")
      
      set_meta_tags(
        og: {
          title: "#{vehicle_config.name} | Openpilot Database",
          image: imgurl,
          url: Rails.application.routes.url_helpers.vehicles_show_url(id: vehicle_config.id),
          type: "website"
        },
        keywords: ['openpilot','vehicle','support',vehicle_config.vehicle_make.name, vehicle_config.vehicle_model.name,vehicle_config.name,'of','vehicles','supported','compatible','compatibility'],
        description: "Research and support of comma openpilot for the #{vehicle_config.name}.",
        canonical: Rails.application.routes.url_helpers.vehicles_show_url(id: vehicle_config.id),
        image_src: imgurl
      )
      super
    end
    def trims
      # byebug
      if !params['vehicle_config'].blank?
        collection = VehicleConfig.find(params['vehicle_config'].to_i).trim_styles.map do |trim_style|
          {
            id: trim_style.vehicle_trim.id,
            name: trim_style.vehicle_trim.name_for_list
          }
        end.uniq
      end

      respond_to do |format|
        format.html
        format.json { render json: collection }
        format.js
      end
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

    def add_to_user
      self.instance = admin.find_instance(params)
      # byebug
      if params['vehicle_trim_style_id'].present?
        vehicle_trim_style = VehicleTrimStyle.find(params['vehicle_trim_style_id']);
      end
      if vehicle_trim_style.present?
        new_user_vehicle = UserVehicle.find_or_initialize_by(user_id: current_user.id, vehicle_config_id: instance.id)
        if new_user_vehicle.vehicle_trim_id == vehicle_trim_style.vehicle_trim.id && new_user_vehicle.vehicle_trim_style_id == vehicle_trim_style.id
          # THEN UNCHECKING
          # REMOVE TRIM
          new_user_vehicle.vehicle_trim_id = nil
          new_user_vehicle.vehicle_trim_style_id = nil
        else
          new_user_vehicle.vehicle_trim_id = vehicle_trim_style.vehicle_trim.id
          new_user_vehicle.vehicle_trim_style_id = params['vehicle_trim_style_id']
        end
        new_user_vehicle.save!
      else
        new_user_vehicle = UserVehicle.find_or_initialize_by(user_id: current_user.id, vehicle_config_id: instance.id)
        if (new_user_vehicle.new_record?)
          new_user_vehicle.save!
        else
          new_user_vehicle.destroy()
        end
      end
      
      
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render json: new_user_vehicle, status: 200 }
      end
    end

    def toggle_capability_state
      self.instance = admin.find_instance(params)
      # byebug
      c = VehicleCapability.find(params['vehicle_capability_id'])
      type = VehicleConfigType.find(params['vehicle_config_type_id'])

      vcc = VehicleConfigCapability.find_or_initialize_by({
        vehicle_config_id: instance.id,
        vehicle_capability_id: params['vehicle_capability_id'],
        vehicle_config_type_id: params['vehicle_config_type_id']
      })

      vcc.state = vcc.next_state

      if vcc.is_included?
        state_message = "included"
      end

      if vcc.is_excluded?
        state_message = "excluded"
      end

      if vcc.not_applicable?
        state_message = "no longer applicable"
      end

      if vcc.is_included?
        case c.value_type
        when 'timeout'
          vcc.timeout = c.default_timeout
        when 'speed'
          vcc.kph = c.default_kph
        end
      end

      vcc.save!
      
      respond_to do |format|
        format.html do
          flash[:message] = flash_message("capability.created", title: "Success!", message: "#{c.name} is now #{state_message} in the #{type.name} configuration.")
          redirect_to "#{request.referer}#!tab-capabilities"
          # redirect_to_return_location(:create, instance, default: admin.instance_path(instance), anchor: "!tab-capabilities")
        end
        format.json { render json: vcc, status: 200 }
      end
    end
  end

  routes do
    get :refresh_trims, :on => :member
    get :fork, :on => :member
    get :clone, :on => :member
    get :toggle_capability_state, :on => :member
    get :vote, :on => :member
    get :add_to_user, :on => :member
    get :refreshing_status, :on => :member
    get :trims, :on => :collection
  end

  table do |a|
    row do |vehicle|
      { class: "#{vehicle.vehicle_config_status.blank? ? nil : vehicle.vehicle_config_status.name.parameterize} #{vehicle.vehicle_config_type.blank? ? "unknown" : vehicle.vehicle_config_type.slug} vehicle-config" }
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
    column :owners, class: 'owners-column' do |vehicle_config|
      if current_user.present?
        owns_this_vehicle = current_user.vehicles.where(vehicle_config_id: vehicle_config.id).count > 0
      else
        owns_this_vehicle = false
      end
      
      # if current_user.present?
        if owns_this_vehicle
          icon_image = "<span class=\'fa fa-check\'></span> <span class=\"message-text\">Owned</span>".html_safe
        else
          icon_image = "<span class=\'fa fa-plus\'></span> <span class=\"message-text\">Own</span>".html_safe
        end

        link_to(
          icon_image, 
          add_to_user_vehicle_configs_admin_url(
            vehicle_config.id,
            format: :json
          ),
          remote: true,
          data: {
            :toggle_link => true
          },
          id: "add_to_garage_vc_#{vehicle_config.id}", 
          class: "btn btn-default btn-own add-vc-link #{owns_this_vehicle ? 'user-owns' : 'user-not-owns'}"
        ) + "<span class=\"message\"><span>#{vehicle_config.user_count}</span> #{vehicle_config.user_count == 1 ? 'person' : 'people'} #{vehicle_config.user_count == 1 ? 'owns' : 'own'} this vehicle.</span>".html_safe
      # end
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
        text_field :source_image_url, label: "Image"
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
              column :own_this_trim, align: :center, class: "garage-column" do |instance|
                # byebug
                if current_user.present?
                  if current_user.vehicles.where(vehicle_trim_style_id: instance.id).count > 0
                    icon_image = '<span class=\'fa fa-check\'></span>'.html_safe
                  else
                    icon_image = '<span class=\'fa fa-plus\'></span>'.html_safe
                  end
                else
                  icon_image = '<span class=\'fa fa-plus\'></span>'.html_safe
                end
          
                link_to(
                  icon_image, 
                  add_to_user_vehicle_configs_admin_url(
                    vehicle_config.id, 
                    format: :json, 
                    params: { 
                      vehicle_trim_style_id: instance.id
                    }
                  ),
                  remote: true,
                  data: {
                    :toggle_link => true
                  },
                  id: "trim_style_#{instance.id}", 
                  class: "add-trim-link"
                )
              end
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
        vcs = VehicleCapability.order(:name)
        vcs_common = vcs.where("vehicle_capabilities.vehicle_config_count > 5")
        vcs_uncommon = vcs.where.not(id: vcs_common.map(&:id))
        vccs = VehicleConfigCapability.joins(:vehicle_config,:vehicle_capability).where(vehicle_config_id: vehicle_config.id)
        render inline: content_tag(:div, nil, class: "table-filter")
        table vcs_common, admin: :vehicle_capabilities_admin do
          column :icon, class: "icon", header: nil do |instance|
            content_tag(:span, class: "icon-wrap") do
              image_tag(asset_url("/assets/capabilities/#{instance.name.parameterize}.svg"),width:100,height:100)
            end
          end
          column :name, header: "Common Capabilities"

          # DIFFICULTY LEVELS
          config_types.each do |type|
          column type.name.parameterize.to_sym, 
            class: "type-#{type.name.parameterize}", 
            header: %(
              #{type.name}
              <span data-toggle='tooltip' data-container='body' title='#{type.description}' class='fa fa-info'></span>
            ).html_safe do |capability|
              render 'capability_link', capability: capability, type: type, vehicle: vehicle_config, vehicle_capability: vccs.select{|vcc| vcc.vehicle_capability_id == capability.id && vcc.vehicle_config_type_id == type.id }.first
            end
          end
        end if vcs_common.present?
        table vcs_uncommon, admin: :vehicle_capabilities_admin do
          column :icon, class: "icon", header: nil do |instance|
            content_tag(:span, class: "icon-wrap") do
              image_tag(asset_url("/assets/capabilities/#{instance.name.parameterize}.svg"),width:100,height:100)
            end
          end
          column :name, header: "Uncommon Capabilities"

          # DIFFICULTY LEVELS
          config_types.each do |type|
          column type.name.parameterize.to_sym, 
            class: "type-#{type.name.parameterize}", 
            header: %(
              #{type.name}
              <span data-toggle='tooltip' data-container='body' title='#{type.description}' class='fa fa-info'></span>
            ).html_safe do |capability|
              render 'capability_link', capability: capability, type: type, vehicle: vehicle_config, vehicle_capability: vccs.select{|vcc| vcc.vehicle_capability_id == capability.id && vcc.vehicle_config_type_id == type.id }.first
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
          # column :image, dialog: true do |instance|
          #   begin
          #     hardware_items = instance.modification.modification_hardware_types.map{|mht| mht.modification.hardware_types.map{|ht| ht.hardware_items.map{|hi| { image: hi.image, name: hi.name, purchase_url: hi.purchase_url } }}}.flatten
          #     if hardware_items.present?
          #       first_item = hardware_items.first
          #       image_tag(first_item.image.service_url)
          #     end
          #   rescue

          #   end
          # end
          column :modification, dialog: true
          column :purchase_required_hardware do |instance|
            # byebug
            begin
              hardware_items = instance.modification.modification_hardware_types.map{|mht| mht.modification.hardware_types.map{|ht| ht.hardware_items.map{|hi| { image: hi.image, name: hi.name, purchase_url: hi.purchase_url } }}}.flatten
              if hardware_items.present?
                first_item = hardware_items.first
                link_to("<span class=\"fa fa-shopping-cart\"></span> Buy #{first_item[:name]}".html_safe, first_item[:purchase_url], class: "btn btn-success", target: "_blank")
              end
            rescue

            end
          end
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
        collection_select :primary_repository_id, Repository.order(:full_name), :id, :name, include_blank: true, label: "Primary Repository"
        collection_select :primary_pull_request_id, PullRequest.order(:pr_updated_at => :desc), :id, :name, include_blank: true, label: "Primary Pull Request"

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
        if vehicle_config.image.attached?
          render inline: image_tag(vehicle_config.image.service_url, class: "profile-image")
          render inline: content_tag(:div, nil, {style: "margin-top:10px;"})
        end
        
        collection_select :vehicle_config_type_id, VehicleConfigType.order(:name), :id, :name, include_blank: true, label: "Minimum Difficulty"
        slack_channel = make.slack_channel
        # byebug
        if slack_channel.present?
          render inline: link_to("<span class=\"fa fa-slack\"></span> #{slack_channel}".html_safe,"slack://channel?team=comma&id=#{slack_channel}", class: "btn btn-slack btn-block")
        else
          render inline: link_to("<span class=\"fa fa-slack\"></span> comma".html_safe,"slack://channel?team=comma", class: "btn btn-slack btn-block")
        end
        render inline: content_tag(:div, nil, {style: "margin-top:10px;"})
        
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
