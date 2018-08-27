Trestle.resource(:videos) do
  menu do
    item :videos, icon: "fa fa-play", group: :documentation
  end
  scope :all, -> { Video.order(:uploaded_at => :desc) }, default: true
  
  # Customize the table columns shown on the index view.
  #
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
    if video.persisted?
      static_field :html, label: "Preview", class: "video-output" do
        content_tag(:div, video.persisted? ? video.html.html_safe : nil, class: "video-output")
      end

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
