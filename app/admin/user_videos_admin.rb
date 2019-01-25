Trestle.resource(:user_videos) do
  # menu do
  #   item :user_videos, icon: "fa fa-star", group: :other
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
  form(dialog:true) do |user_video|
    is_new_video = params['new'].present?
    is_edit_video = params['edit'].present?
    is_from_url = params['from_url'].present?
    video = user_video.video
    
    if user_video.user.blank?
      if params[:user_id]
        user = User.find(params[:user_id])
        user_video.user = user
      end
    else
      user = user_video.user
    end
    if !user.blank?
      static_field :user, user.name
      
      hidden_field :user_id
    else
      collection_select :user_id, User.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :user_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, user_types.difficulty_level"), :id, :name, include_blank: true
    end
    if is_from_url
      fields_for :video, user_video.video || user_video.build_video do
        # Form helper methods now dispatch to the product.category form scope
        text_field :video_url
      end
    else
      if (is_new_video || is_edit_video)
        fields_for :video, user_video.video || user_video.build_video do
          # Form helper methods now dispatch to the product.category form scope
          text_field :title
          # editor :markdown, label: false
        end
      else
        collection_select :video_id, Video.where.not(:id => UserVideo.select(:id).where(user_id: user.id)).order(:author,:uploaded_at => :desc), :id, :name_with_author, include_blank: true
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
  #   params.require(:user_video).permit(:name, ...)
  # end
end
