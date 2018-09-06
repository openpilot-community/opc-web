Trestle.resource(:vehicle_config_videos) do
  # menu do
  #   item :vehicle_config_videos, icon: "fa fa-star", group: :other
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  form(dialog:true) do |vehicle_config_video|
    is_new_video = params['new'].present?
    is_edit_video = params['edit'].present?
    is_from_url = params['from_url'].present?
    video = vehicle_config_video.video
    
    if vehicle_config_video.vehicle_config.blank?
      if params[:vehicle_config_id]
        vehicle_config = VehicleConfig.find(params[:vehicle_config_id])
        vehicle_config_video.vehicle_config = vehicle_config
      end
    else
      vehicle_config = vehicle_config_video.vehicle_config
    end
    if !vehicle_config.blank?
      static_field :vehicle_config, vehicle_config.name
      
      hidden_field :vehicle_config_id
    else
      collection_select :vehicle_config_id, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :vehicle_config_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, vehicle_config_types.difficulty_level"), :id, :name, include_blank: true
    end
    if is_from_url
      fields_for :video, vehicle_config_video.video || vehicle_config_video.build_video do
        # Form helper methods now dispatch to the product.category form scope
        text_field :video_url
      end
    else
      if (is_new_video || is_edit_video)
        fields_for :video, vehicle_config_video.video || vehicle_config_video.build_video do
          # Form helper methods now dispatch to the product.category form scope
          text_field :title
          # editor :markdown, label: false
        end
      else
        collection_select :video_id, Video.order(:title), :id, :title, include_blank: true
      end
    end
    
    static_field :html, label: "Preview", class: "video-output" do
      content_tag(:div, video.present? && video.html.present? ? video.html.html_safe : nil, class: "video-output")
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
  #   params.require(:vehicle_config_video).permit(:name, ...)
  # end
end
