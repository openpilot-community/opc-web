Trestle.resource(:guides) do
  to_param do |instance|
    if instance.slug.present?
      instance.slug
    else
      instance.id
    end
  end
  find_instance do |params|
    Guide.friendly.find(params[:id])
  end
  controller do
    skip_before_action :require_edit_permissions!
    skip_before_action :require_super_admin!
    def show
      self.instance = admin.find_instance(params)
      commontator_thread_show(instance)
      # @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Vehicle Research and Support","/vehicle_configs")])
      imgurl = instance.image.attached? ? instance.image.service_url : asset_url("/assets/og/tracker.png")
      article_url = File.join(Rails.application.routes.url_helpers.root_url,admin.instance_path(instance))
      author_name = instance.user.github_username
      set_meta_tags(
        og: {
          title: "#{instance.title}",
          image: imgurl,
          site_name: "Openpilot Database",
          url: article_url,
          type: "article",
          author: author_name
        },
        robots: "index, follow",
        "article:published_time": instance.created_at.iso8601(9),
        "article:publisher": "https://opc.ai/",
        "article:author": author_name,
        keywords: ['openpilot','vehicle','support',instance.title.split,'of','vehicles','supported','compatible','compatibility'].flatten,
        description: "Research and support of comma openpilot for the #{instance.name}.",
        canonical: article_url,
        image_src: imgurl,
        author: author_name,
        twitter: {
          creator: "@#{author_name}",
          title: instance.title,
          card: "summary-large",
          author: author_name,
          label1: "Reading time",
          data1: "#{instance.reading_time} min read"
        }
      )
      super
    end
    # before_action :set_current_user, only: ['create','update']
    def create
      self.instance = admin.build_instance(permitted_params, params)
      self.instance.user = current_user
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
            flash.now[:error] = flash_message("create.failure", title: "Warning!", message: "Please correct the errors below.")
            render "new", status: :unprocessable_entity
          end
          format.json { render json: instance.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end
  end
  return_to do
    admin.path(:index) || params[:return_location] || :back
  end
  # Customize the table columns shown on the index view.
  #
  table do
    column :title, header: "" do |instance|
      render "row", instance: instance, vehicle_config: {}, vehicle_config_guide: {}
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |guide|
    tab :general do
      if params['from_url'].present?
        text_field :article_source_url
        select :hardware_item_ids, HardwareItem.all.order(:name), { label: "Tag hardware in this guide" }, { multiple: true, data: { tags: true } }
        select :vehicle_config_ids, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level"), { label: "Tag vehicles in this guide" }, { multiple: true, data: { tags: true } }
      else
        text_field :title
        select :hardware_item_ids, HardwareItem.all.order(:name), { label: "Tag hardware in this guide" }, { multiple: true, data: { tags: true } }
        select :vehicle_config_ids, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level"), { label: "Tag vehicles in this guide" }, { multiple: true, data: { tags: true } }
        editor :markdown, { label: "" }
        
        if current_user.is_super_admin?
          collection_select :user_id, User.order(:github_username), :id, :github_username, include_blank: true, label: "Author"
        end
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
  #   params.require(:guide).permit(:name, ...)
  # end
end
