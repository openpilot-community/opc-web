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

  search do |query|
    if query
      query = query.titleize
      Guide.search_for("#{query}").select { |r| r.published? }
    else
      Guide.where.not(slug: nil,title: "New Untitled Guide").order(:updated_at => :desc)
    end
  end

  collection do |params|
    Guide.where.not(slug: nil,title: "New Untitled Guide").order(:updated_at => :desc)
  end
  
  controller do
    skip_before_action :require_edit_permissions!
    # skip_before_action :require_super_admin!
    include ActionView::Helpers::AssetUrlHelper
    include ActionView::Helpers::SanitizeHelper

    def new
      new_guide = Guide.new(user: current_user, title: "New Untitled Guide", markdown: "The beginning of a new article...")
      new_guide.save!
      self.instance = admin.find_instance(new_guide)
      
      @uploader_model_name = "guide"
      @uploader_model_id = instance.id
    end

    def show
      self.instance = admin.find_instance(params)
      self.instance.full_url = File.join(Rails.application.routes.url_helpers.root_url,admin.instance_path(instance))
      imgurl = instance.latest_image.present? ? instance.latest_image.attachment_url : asset_url("/assets/og/tracker.png")
      article_url = File.join(Rails.application.routes.url_helpers.root_url,admin.instance_path(instance))
      author_name = instance.author[:name]
      exerpt = (instance.markup.present? ? strip_tags(instance.markup).truncate_words(25) : nil).strip!
      set_meta_tags(
        title: instance.title,
        og: {
          title: "#{instance.title}",
          image: imgurl,
          "image:width": instance.latest_image.present? && instance.latest_image.width.present? ? instance.latest_image.width : nil,
          "image:height": instance.latest_image.present? && instance.latest_image.height.present? ? instance.latest_image.height : nil,
          description: exerpt,
          site_name: "Openpilot Community",
          url: article_url,
          type: "article",
          author: author_name
        },
        robots: "index, follow",
        "article:published_time": instance.created_at.iso8601(9),
        "article:publisher": "https://opc.ai/",
        "article:author": author_name,
        keywords: ['openpilot','vehicle','support',instance.title.split,'of','vehicles','supported','compatible','compatibility'].flatten,
        description: exerpt,
        canonical: article_url,
        image_src: imgurl,
        author: author_name,
        twitter: {
          creator: "@#{author_name}",
          title: instance.title,
          # card: "summary-large",
          description: exerpt,
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
        text_field :article_source_url, { label: "Add Guide from URL:", placeholder: "Type the URL of the article to scrape it"}
      else
        text_field :title
        text_area :markdown, { label: "", class: "simplemde-inline" }
        text_area :exerpt
        # text_area :exerpt
      end
    end

    sidebar do
      if guide.latest_image.present?
        render inline: image_tag(guide.latest_image.attachment_url, class: "profile-image")
        
        render inline: content_tag(:div, nil, {style: "margin-top:10px;"})
      end
      # text_field :source_image_url, label: "Change Image", placeholder: "Enter URL to Update"
      select :hardware_item_ids, HardwareItem.all.order(:name), { label: "Tag hardware in this guide" }, { multiple: true, data: { tags: true } }
      select :vehicle_config_ids, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_config_type, :vehicle_config_status, :repositories, :pull_requests, :vehicle_config_pull_requests).order("vehicle_makes.name, vehicle_models.name, year, vehicle_config_types.difficulty_level"), { label: "Tag vehicles in this guide" }, { multiple: true, data: { tags: true } }
      if params['from_url'].blank?
        text_field :author_name
        text_area :exerpt
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
