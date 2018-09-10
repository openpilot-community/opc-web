Trestle.admin(:dashboard) do
  menu do
    group :vehicles do
      item :vehicle_configs, "/vehicles", icon: "fa fa-book", label: "Research / Support", priority: 1.0
      item :lookup, "/lookup", icon: "fa fa-plus", label: "Lookup a vehicle", priority: 1.3
      
      VehicleMake.with_configs.each_with_index do |make, index|
        item(make.name.parameterize.to_sym, "/vehicles/make/#{make.name.parameterize.downcase}", icon: "fa fa-angle-right", priority: "1.6.#{index+3}".to_f)
      end
    end

    group :getting_started do
      item :guides, '/guides', icon: "fa fa-pencil", priority: 3.0
      item :hardware_items, '/hardware_items', icon: "fa fa-microchip", label: "Hardware", priority: 3.3
      item :videos, '/videos', icon: "fa fa-video-camera", priority: 3.6
    end

    group :tools do
      item :cabana, 'https://community.comma.ai/cabana', icon: "fa fa-bug", priority: 4.0
      item :explorer, 'https://my.comma.ai/', icon: "fa fa-road", priority: 4.3
      item :driving_explorer, 'https://community.comma.ai/explorer.php', icon: "fa fa-play", priority: 4.6
      item :slack_archives, 'http://comma.advil0.com/', icon: 'fa fa-slack', priority: 4.9
    end

    group :support do
      item :slack, 'https://comma.slack.com/', priority: 6.0
      item :pull_requests, '/pull_requests', icon: "fa fa-github", priority: 6.6
      item :repositories, '/repositories', icon: "fa fa-github", priority: 6.9
      item :contributors, '/contributors', icon: "fa fa-users", priority: 6.12
    end

    group :admin do
      item :hardware_items, '/hardware_items', icon: "fa fa-microchip", label: "Hardware Items", priority: 20.3
      item :hardware_types, '/hardware_types', icon: "fa fa-microchip", label: "Hardware Types", priority: 20.6
      item :vehicle_capabilities, '/vehicle_capabilities', icon: "fa fa-star", priority: 20.9
      item :vehicle_makes, '/vehicle_makes', icon: "fa fa-car", label: "Makes", priority: 20.13
      item :vehicle_config_statuses, icon: "fa fa-star", label: "Support Statuses", priority: 20.16
      item :tools, '/tools', icon: "fa fa-wrench", priority: 20.19
      item :vehicle_make_packages, '/vehicle_make_packages', icon: "fa fa-star",label: "Makes Packages", priority: 20.23
      item :vehicle_config_types, '/vehicle_config_types', icon: "fa fa-star", label: "Difficulty Levels", priority: 20.26
    end

    group :super_admin do
      item :vehicle_lookups, icon: "fa fa-star", priority: 33.0
      item :users, '/users', icon: "fa fa-users", priority: 33.3
      item :user_vehicles, icon: "fa fa-star", priority: 33.6
    end
  end

  controller do

  end

  routes do

  end
end
