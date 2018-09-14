Trestle.resource(:topics, model: Thredded::Topic) do
  controller do
    def show
      super
      vehicle = VehicleConfig.find_by(thredded_messageboard_id: instance.messageboard_id)
      if vehicle.present?
        @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new(instance.messageboard.name, vehicle_configs_admin_url(vehicle.slug, anchor: "!tab-discuss"))])
      else
        @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Discuss", "/thredded_topics")])
      end
    end

    def index
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Discuss", "/thredded_topics")])
      super
    end
  end

  form do |topic|
    text_field :title
    fields_for :first_post, topic.first_post || topic.build_first_post do
      # Form helper methods now dispatch to the product.category form scope
      hidden_field :messageboard_id, value: topic.messageboard_id
      hidden_field :user_id, value: current_user.id
      hidden_field :moderation_state, value: "approved"
      text_area :content, { label: false, class: "simplemde-inline", placeholder: "What's on your mind?" }
    end
  end

  table do
    row do
      {
        data: {
          behavior: "dialog"
        },
        modalClass: "teste"
      }
    end
    column :row, header: false do |instance|
      render "row", instance: instance
    end
  end
end
