Trestle.resource(:user_vehicles) do

  controller do
    def index
      @breadcrumbs = Trestle::Breadcrumb::Trail.new([Trestle::Breadcrumb.new("Your Garage", "/garage")])

      self.collection = admin.prepare_collection(params)
      respond_to do |format|
        format.html
        format.json { render json: collection.where(user_id: current_user.id) }
      end
    end

    def show
      self.instance = admin.find_instance(params)

      if instance.user_id == current_user.id
        respond_to do |format|
          format.html
          format.json { render json: collection.where(user_id: current_user.id) }
        end
      end
    end
  end
  # Customize the table columns shown on the index view.
  #
  table do
    column :votes, align: :center, class: "votes-column" do |user_vehicle|
      content_tag(:div, class: "vote-action #{current_or_guest_user.voted_down_on?(user_vehicle.vehicle_config) ? "downvoted" : nil} #{current_or_guest_user.voted_up_on?(user_vehicle.vehicle_config) ? 'upvoted' : nil} #{current_or_guest_user.voted_for?(user_vehicle.vehicle_config) ? "voted" : nil}") do
        %(
        #{link_to('<span class=\'fa fa-arrow-up\'></span>'.html_safe, vote_vehicle_configs_admin_url(user_vehicle.vehicle_config.id, :format=> :json, params: { vote: 'up' }), remote: true, id: "vote_up_#{user_vehicle.vehicle_config.id}", class: "vote-up ")}
        #{content_tag :span, user_vehicle.vehicle_config.cached_votes_score, class: "badge badge-vote-count"}
        #{link_to('<span class=\'fa fa-arrow-down\'></span>'.html_safe, vote_vehicle_configs_admin_url(user_vehicle.vehicle_config.id, :format=> :json, params: { vote: 'down' }), remote: true, id: "vote_down_#{user_vehicle.vehicle_config.id}", class: "vote-down ")}
        ).html_safe
      end.html_safe
    end
    column :image, class: "image-column" do |user_vehicle|
      if user_vehicle.vehicle_config.image.attached?
        image_tag(user_vehicle.vehicle_config.image.service_url)
      end
    end
    column :vehicle, class: "details-column" do |user_vehicle|
      render "vehicle_config_details", instance: user_vehicle.vehicle_config
    end
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |user_vehicle|
    has_vehicle_config = user_vehicle.vehicle_config.present?
    has_vehicle_trim = user_vehicle.vehicle_trim.present?
    has_vehicle_trim_style = user_vehicle.vehicle_trim_style.present?
    if has_vehicle_config
      vehicle_config = user_vehicle.vehicle_config
      static_field :vehicle_config, vehicle_config.name
      hidden_field :vehicle_config_id
    else
      collection_select :vehicle_config_id, VehicleConfig.includes(:vehicle_make, :vehicle_model, :vehicle_trim, :vehicle_config_type).order("vehicle_makes.name, vehicle_models.name, vehicle_trims.name, year, vehicle_config_types.difficulty_level"), :id, :name, disabled: true, include_blank: true
    end
    if has_vehicle_trim
      vehicle_trim = user_vehicle.vehicle_trim
      static_field :vehicle_trim, vehicle_trim.name
      hidden_field :vehicle_trim_id
    else
      collection_select :vehicle_trim_id, [], :id, :name, disabled: true, include_blank: true
    end
    if has_vehicle_trim_style
      vehicle_trim_style = user_vehicle.vehicle_trim_style
      static_field :vehicle_trim_style, vehicle_trim_style.name
      hidden_field :vehicle_trim_style_id
    else
      collection_select :vehicle_trim_style_id, [], :id, :name, disabled: true, include_blank: true
    end
    
    # row do
    #   col(xs: 6) { datetime_field :updated_at }
    #   col(xs: 6) { datetime_field :created_at }
    # end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:user_vehicle).permit(:name, ...)
  # end
end
