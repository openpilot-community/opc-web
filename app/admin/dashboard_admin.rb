Trestle.admin(:dashboard) do
  menu do
    
    group :getting_started do
      item :lookup, "/lookup", icon: "fa fa-search", label: "Lookup your vehicle", priority: 0.1
      item :vehicle_configs, "/vehicles", icon: "fa fa-car", label: "Vehicles", priority: 0.2
      item :hardware_items, '/hardware_items', icon: "fa fa-microchip", label: "Hardware", priority: 0.3
      item :guides, '/guides', icon: "fa fa-graduation-cap", priority: 0.5
      item :videos, '/videos', icon: "fa fa-video-camera", priority: 0.8
      item :topics, '/topics', icon: "fa fa-comments", label: "Discuss", priority: 0.9, badge: 0
    end

    group :external_tools do
      item :slack, 'https://comma.slack.com/', priority: 1.3
      item :cabana, 'https://community.comma.ai/cabana', icon: "fa fa-bug", priority: 1.6
      item :explorer, 'https://my.comma.ai/', icon: "fa fa-road", priority: 1.9
      item :driving_explorer, 'https://community.comma.ai/explorer.php', icon: "fa fa-play", priority: 1.13
      # item :slack_archives, 'http://comma.advil0.com/', icon: 'fa fa-slack', priority: 4.9
    end

    group :admin do
      item :pull_requests, '/pull_requests', icon: "fa fa-github", priority: 6.6
      item :contributors, '/contributors', icon: "fa fa-users", priority: 6.12
      item :repositories, '/repositories', icon: "fa fa-github", priority: 6.9
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
      item :vehicle_lookups, '/vehicle_lookups', icon: "fa fa-star", priority: 33.0
      item :users, '/users', icon: "fa fa-users", priority: 33.3
      item :user_vehicles, '/user_vehicles', icon: "fa fa-star", priority: 33.6
    end
  end

  controller do

  end

  routes do

  end
end
