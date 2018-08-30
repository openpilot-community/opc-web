Trestle.resource(:videos) do
  menu do
    item :videos, group: :admin
  end
  scope :all, -> { Video.order(:uploaded_at => :desc) }, default: true
  
  # Customize the table columns shown on the index view.
  #
  controller do
    include ActionView::Helpers::AssetUrlHelper
    def show
      video = admin.find_instance(params)
      
      set_meta_tags og: {
        title: "#{video.title} | Openpilot Database",
        image: video.thumbnail_url,
        type: "website",
        description: video.description
      }
      set_meta_tags keywords: [video.title.split(' '),['openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility']].flatten
      set_meta_tags description: video.description
      super
    end
  end
  table do
    column :thumbnail do |video|
      image_tag(video.thumbnail_url, width: '150')
    end
    column :name
    # column :vehicle_config_videos
    column :uploaded_at
    # column :created_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |video|
    tab :general do
      if video.persisted?
        # static_field :html, label: "Preview", class: "video-output" do
        #   content_tag(:div, video.persisted? ? video.html.html_safe : nil, class: "video-output")
        # end

        text_field :title
        text_field :provider_name
        text_field :author
        text_field :author_url
        text_field :thumbnail_url
        text_field :description
        # text_field :html
        text_field :uploaded_at
      else
        text_field :video_url
      end
    end

    sidebar do
      static_field :html, label: "Preview", class: "video-output" do
        content_tag(:div, video.persisted? ? video.html.html_safe : nil, class: "video-output")
      end
      
      static_field :html, label: "Vehicle(s)" do
        content_tag(:ul) do
          video.vehicle_configs.map do |config|
            content_tag(:li) do
              config.name
            end.html_safe
          end.join('').html_safe
        end
      end
      # collection_select :parent_id, VehicleConfig.where.not(id: vehicle_config.id).includes(:vehicle_make,:vehicle_model).where(:vehicle_make => vehicle_config.vehicle_make.blank? ? nil : vehicle_config.vehicle_make,:vehicle_model => vehicle_config.vehicle_model.blank? ? nil : vehicle_config.vehicle_model).where("parent_id IS NULL").order("vehicle_models.name, year"), :id, :name, include_blank: true, label: "Associate to new parent"
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
  #   params.require(:video).permit(:name, ...)
  # end
end
