Trestle.resource(:video_hardware_items) do
  # menu do
  #   item :video_hardware_items, icon: "fa fa-star", group: :other
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
  form(dialog: true) do |video_hardware_item|
    is_new_video = params['new'].present?
    is_edit_video = params['edit'].present?
    is_from_url = params['from_url'].present?
    
    if video_hardware_item.hardware_item.blank?
      if params[:hardware_item_id]
        hardware_item = HardwareItem.find(params[:hardware_item_id])
        video_hardware_item.hardware_item = hardware_item
      end
    else
      hardware_item = video_hardware_item.hardware_item
    end

    if is_new_video
      vehicle_label = "Writing a new video for the "
    elsif is_edit_video
      vehicle_label = "Editing this video for the "
    else
      vehicle_label = "Linking a video to "
    end

    if hardware_item.present?
      static_field :hardware_item, hardware_item.name, label: vehicle_label
      hidden_field :hardware_item_id
    end

    if is_edit_video
      render inline: content_tag(
        :div,
        "<h4>READ BEFORE PROCEEDING</h4> You are editing an existing video.  This video may not be specific to this piece of hardware.  Ensure it is a hardware specific video before adding content that might pertain to it.".html_safe,
        class: "alert alert-warning",
          style: "display:block;"
      )
    end

    if is_from_url
      fields_for :video, video_hardware_item.video || video_hardware_item.build_video do
        # Form helper methods now dispatch to the product.category form scope
        text_field :video_url
        # select :hardware_item_ids, HardwareItem.all.order(:name), {label: "Tag hardware in this video"}, {prompt: "Choose an existing video"}, { multiple: true, data: { tags: true } }
      end
    else
      if (is_new_video || is_edit_video)
        
        fields_for :video, video_hardware_item.video || video_hardware_item.build_video do
          # Form helper methods now dispatch to the product.category form scope
          text_field :video_url
        end
      else
        collection_select :video_id, Video.order(:title), :id, :title, include_blank: true
      end
    end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://videos.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:video_hardware_item).permit(:name, ...)
  # end
end
