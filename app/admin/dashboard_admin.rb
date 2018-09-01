Trestle.admin(:dashboard) do
  menu do
    group :vehicles do
      item :vehicle_configs, "/research", icon: "fa fa-book", label: "Research / Support", priority: 0
      item :top_vehicle_configs, '/vehicle_configs?order=desc&sort=cached_votes_score', icon: "fa fa-star", label: "Top Voted Vehicles", priority: 0.1
      item :lookup, "/lookup", icon: "fa fa-plus", label: "Lookup a vehicle", priority: 0.2
      
      VehicleMake.with_configs.each_with_index do |make, index|
        item make.name.parameterize.to_sym, "#{Rails.application.routes.url_helpers.research_make_url(q: make.name.parameterize.downcase)}", icon: "fa fa-angle-right", priority: "0.3.#{index+3}".to_f
      end
    end

    group :community do
      item :slack, 'https://comma.slack.com/', priority: 1
      item :videos, '/videos', icon: "fa fa-play", priority: 1.2
      item :pull_requests, '/pull_requests', icon: "fa fa-github", priority: 1.3
      item :repositories, '/repositories', icon: "fa fa-github", priority: 1.4
      item :contributors, '/contributors', icon: "fa fa-users", priority: 1.5
    end

    group :tools do
      item :cabana, 'https://community.comma.ai/cabana', icon: "fa fa-bug", priority:2
      item :explorer, 'https://my.comma.ai/', icon: "fa fa-road", priority:2.1
      item :driving_explorer, 'https://community.comma.ai/explorer.php', icon: "fa fa-play", priority: 2.2
      item :slack_archives, 'http://comma.advil0.com/', icon: 'fa fa-slack', priority: 2.3
    end

    group :admin do
      item :modifications, '/modifications', icon: "fa fa-wrench", priority:3
      item :guides, '/guides', icon: "fa fa-pencil", priority:3.1
      item :hardware_items, '/hardware_items', icon: "fa fa-microchip", label: "Hardware Items", priority:3.2
      item :hardware_types, '/hardware_types', icon: "fa fa-microchip", label: "Hardware Types", priority:3.3
      item :vehicle_capabilities, '/vehicle_capabilities', icon: "fa fa-star", priority:3.4
      item :vehicle_makes, '/vehicle_makes', icon: "fa fa-car", label: "Makes", priority:3.5
      item :vehicle_config_statuses, icon: "fa fa-star", label: "Support Statuses", priority:3.6
      item :tools, '/tools', icon: "fa fa-wrench", priority:3.7
      item :vehicle_make_packages, '/vehicle_make_packages', icon: "fa fa-star",label: "Makes Packages", priority:3.8
      item :vehicle_config_types, '/vehicle_config_types', icon: "fa fa-star", label: "Difficulty Levels", priority:3.9
    end

    group :super_admin do
      item :vehicle_lookups, icon: "fa fa-star", priority:4
      item :users, '/users', icon: "fa fa-users"
      item :user_vehicles, icon: "fa fa-star"
    end
  end

  controller do

  end

  routes do

  end
  # scope :all, -> { Contributor.order(:contributions => :desc) }, default: true
  
  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name do |contributor|
  #     link_to contributor.html_url, target: "_blank" do
  #       "#{image_tag(contributor.avatar_url, width: "50")} #{contributor.username}".html_safe
  #     end
  #   end
  #   column :contributions
  #   # actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |contributor|
  #   text_field :name
  #
  #   row do
  #     col(xs: 6) { datetime_field :updated_at }
  #     col(xs: 6) { datetime_field :created_at }
  #   end
  # end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:contributor).permit(:name, ...)
  # end
end
