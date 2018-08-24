Trestle.resource(:videos) do
  menu do
    item :videos, icon: "fa fa-play", group: :documentation, badge: Video.all.count
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :thumbnail do |video|
      image_tag(video.thumbnail_url, width: '150')
    end
    column :name
    column :created_at, align: :center
  end

  # Customize the form fields shown on the new/edit views.
  #
  form(dialog: true) do |video|
    text_field :title
    text_field :video_url
    text_field :provider_name
    text_field :author
    text_field :author_url
    text_field :thumbnail_url
    text_field :description
    text_field :html
    text_field :uploaded_at
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
