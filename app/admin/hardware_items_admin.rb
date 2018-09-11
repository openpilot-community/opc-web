Trestle.resource(:hardware_items) do
  to_param do |instance|
    if instance.slug.present?
      instance.slug
    else
      instance.id
    end
  end
  collection do |params|
    HardwareItem.all.order(:name)
  end
  find_instance do |params|
    HardwareItem.friendly.find(params[:id])
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
      author_name = "The Openpilot Community"
      set_meta_tags(
        og: {
          title: "#{instance.name}",
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
        keywords: ['openpilot','vehicle','support',instance.name.split,'of','vehicles','supported','compatible','compatibility'].flatten,
        description: "Research and support of comma openpilot for the #{instance.name}.",
        canonical: article_url,
        image_src: imgurl,
        author: author_name,
        twitter: {
          creator: "@#{author_name}",
          title: instance.name,
          card: "summary-large",
          author: author_name
        }
      )
      super
    end
    # before_action :set_current_user, only: ['create','update']
  end
  table do
    column :title, header: "" do |instance|
      render "row", instance: instance, vehicle_config: {}, vehicle_config_guide: {}
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |hardware_item|
    tab :general do
      text_field :name
      text_field :alternate_name
      text_area :description, { class: "simplemde-inline" }
      
      text_area :notes
      text_field :image_url
      text_field :install_guide_url
      text_field :source_image_url
    end
    tab :videos, label: '<span class="fa fa-video-camera"></span> Videos'.html_safe, badge: hardware_item.video_hardware_items.blank? ? nil : hardware_item.video_hardware_items.size do
      render "tab_toolbar", {
        :groups => [
          {
            :class => "actions",
            :items => [
              content_tag(:span,"Add a video: ", class: "btn btn-default disabled", style: "color:#212121;"),
              admin_link_to("<span class=\"fa fa-plus\"></span> Existing".html_safe, admin: :video_hardware_items, action: :new, class: "btn btn-default btn-list-add", params: { hardware_item_id: hardware_item.blank? ? nil : hardware_item.id }),
              admin_link_to("<span class=\"fa fa-plus\"></span> From URL".html_safe, admin: :video_hardware_items, action: :new, class: "btn btn-default btn-list-add", params: { from_url: true, hardware_item_id: hardware_item.blank? ? nil : hardware_item.id })
            ]
          }
        ]
      }
      table hardware_item.video_hardware_items, admin: :video_hardware_items do
        row do |instance|
          key = instance.video.slug.present? ? instance.video.slug : instance.video.id
          {
            data: {
              url: videos_admin_url(key)
            }
          }
        end
        column :row, header: false do |video_hardware_item|
          render "admin/videos/row", instance: video_hardware_item.video
        end
      end
    end
    tab :guides, label: "<span class=\"fa fa-file-text\"></span> Guides".html_safe, badge: hardware_item.guides.present? ? hardware_item.guides.size : nil do
      render "tab_toolbar", {
        :groups => [
          {
            :class => "filters",
            :items => [
              link_to(
                "All",
                hardware_items_admin_url(hardware_item.id, anchor: "!tab-guides"), 
                class: "btn btn-default btn-list-filter"
              ),
              VehicleConfigType.where.not(difficulty_level: 0).order(:difficulty_level).map do |difficulty|
                link_to(difficulty.name, hardware_items_admin_url(hardware_item.id, params: { difficulty: difficulty.id }, anchor: "!tab-guides"), class: "btn btn-default btn-list-filter")
              end
            ].flatten
          },
          {
            :class => "actions",
            :items => [
              content_tag(:span,"Add a guide: ", class: "btn btn-default disabled", style: "color:#212121;"),
              admin_link_to("<span class=\"fa fa-plus\"></span> Existing".html_safe, admin: :guide_hardware_items, action: :new, class: "btn btn-default btn-list-add", params: { hardware_item_id: hardware_item.blank? ? nil : hardware_item.id }),
              admin_link_to("<span class=\"fa fa-plus\"></span> URL".html_safe, admin: :guide_hardware_items, action: :new, class: "btn btn-default btn-list-add", params: { from_url: true, hardware_item_id: hardware_item.blank? ? nil : hardware_item.id }),
              admin_link_to("<span class=\"fa fa-pencil\"></span> Write".html_safe, admin: :guide_hardware_items, action: :new, dialog: true, class: "btn btn-default btn-list-add", params: { new: true, hardware_item_id: hardware_item.blank? ? nil : hardware_item.id })
            ]
          }
        ]
      }

      if params['difficulty']
        difficulty = VehicleConfigType.where(id: params['difficulty'].to_i)
        if difficulty.present?
          guides_qry = hardware_item.guide_hardware_items.where(hardware_items_type_id: difficulty.first.id).includes(:guide).order('guides.title')
        else
          guides_qry = hardware_item.guide_hardware_items.includes(:guide).order('guides.title')
        end
      else
        guides_qry = hardware_item.guide_hardware_items.includes(:guide).order('guides.title')
      end

      if guides_qry.present?
        table guides_qry, admin: :guide_hardware_items, action: :show, params: { show: true } do
          row do |guide|
            { 
              data: {
                url: guide_hardware_items_admin_url(guide.id, params: { show: true }) 
              }
            }
          end
          column :row, dialog: true, header: nil do |instance|
            render "admin/guides/row", instance: instance.guide, guide_hardware_item: instance, hardware_item: hardware_item
          end
          # column :title, dialog: true do |instance|
          #   instance.guide.title
          # end
          # column :purchase_required_hardware do |instance|
          #   # byebug
          #   begin
          #     hardware_items = instance.modification.modification_hardware_types.map{|mht| mht.modification.hardware_types.map{|ht| ht.hardware_items.map{|hi| { image: hi.image, name: hi.name, purchase_url: hi.purchase_url } }}}.flatten
          #     if hardware_items.present?
          #       first_item = hardware_items.first
          #       link_to("<span class=\"fa fa-shopping-cart\"></span> Buy #{first_item[:name]}".html_safe, first_item[:purchase_url], class: "btn btn-success", target: "_blank")
          #     end
          #   rescue

          #   end
          # end
        end
      else
        render inline: content_tag(
          :div, 
          %(
            <h4><strong>No Guides for #{hardware_item.name} Yet!</strong></h4>
            <p>We need your help linking existing guides or writing new ones for this piece of hardware. 
            It's fast and easy and only has to be done once for everyone to benefit. 
            Teach others from your experiences.
            </p>
            <p>Be the first to add one now.</p>
          ).html_safe, 
          class: "alert alert-warning", 
          style: "display: block;"
        )
      end
    end if hardware_item.persisted?
    sidebar do
      if hardware_item.image.attached?
        render inline: image_tag(hardware_item.image.service_url, class: "profile-image")
      end
      collection_select :hardware_type_id, HardwareType.order(:name), :id, :name, include_blank: true, label: "Type"
      check_box :compatible_with_all_vehicles
      check_box :available_for_purchase
      text_field :purchase_url
      check_box :requires_assembly
      check_box :can_be_built
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
  #   params.require(:hardware_item).permit(:name, ...)
  # end
end
