Trestle.resource(:posts, model: Thredded::Post) do
  form(dialog:true) do |instance|
    if instance.postable.blank?
      if params[:postable_id]
        postable = Thredded::Topic.find(params[:postable_id])
        instance.postable = postable
      end
    else
      postable = instance.postable
    end
    if !postable.blank?
      static_field :postable, postable.title
      
      hidden_field :postable_id
    else
      collection_select :postable_id, Thredded::Topic.all, :id, :name, include_blank: true
    end
    # collection_select :pull_request_id, PullRequest.order(:pr_updated_at => :desc), :id, :name, include_blank: true
    hidden_field :messageboard_id, value: postable.messageboard_id
    hidden_field :postable_id, value: params[:postable_id]
    hidden_field :user_id, value: current_user.id
    hidden_field :moderation_state, value: "approved"
    text_area :content
  end
  # controller do
    # def show
    #   super
    #   vehicle = VehicleConfig.find_by(thredded_messageboard_id: instance.messageboard_id)
    #   if vehicle.present?
    #     @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new(instance.messageboard.name, vehicle_configs_admin_url(vehicle.slug, anchor: "!tab-discuss"))])
    #   else
    #     @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Discuss", "/thredded_topics")])
    #   end
    # end

    # def index
    #   @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Discuss", "/thredded_topics")])
    #   super
    # end
  # end

  # table do
  #   column :row, header: false do |instance|
  #     render "row", instance: instance
  #   end
  # end

end
