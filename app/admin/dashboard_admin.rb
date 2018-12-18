Trestle.admin(:dashboard) do
  menu do
    group :database do
      item :vehicle_configs, "/vehicles", icon: "fa fa-car", label: "Vehicles", priority: 0.1
      item :lookup, "/lookup", icon: "fa fa-search", label: "Lookup your vehicle", priority: 0.2
      item :hardware_items, '/hardware_items', icon: "fa fa-microchip", label: "Hardware", priority: 0.3
      item :guides, '/guides', icon: "fa fa-graduation-cap", priority: 0.5
      item :videos, '/videos', icon: "fa fa-video-camera", priority: 0.8
      # item :topics, '/topics', icon: "fa fa-comments", label: "Discuss", priority: 0.9, badge: 0
    end

    group :resources do
      item :discord, 'https://discord.gg/Wyna3qy', label: "<span class=\"fa\"><img src=\"https://img.icons8.com/color/180/discord-new-logo.png\" style=\"width: 40px;position:absolute;left:18px;top:4px;\" /></span> <span style=\"color:#FFFFFF;padding-left:15px;\"><strong>Discord</strong></span>&nbsp;&nbsp;<span style=\"padding-left: 48px;font-size: 12px;display:block;font-weight: 400;\">Join the discussion!</span>".html_safe, icon: "fa fa-discord", priority: 1.60
      item :workbench, '/workbench', label: "<span class=\"fa\"><img src=\"https://opc.ai/assets/workbench-icon-f733d1c9b5e50e4165cbe8e72c6919391e766bfb276da0f4642530e6d6f539cc.png\" style=\"width: 40px;position:absolute;left:18px;top:4px;\" /></span> <span style=\"color:#FFFFFF;padding-left:15px;\"><strong>Workbench</strong></span><span style=\"padding-left: 48px;font-size: 12px;display:block;font-weight: 400;\">A new tool to manage EON!</span>".html_safe, icon: "fa fa-download", priority: 1.61
      # item :slack_archives, 'https://comma.advil0.com/', icon: 'fa fa-slack', priority: 4.9
    end
    
    group :comma do
      item :explorer, 'https://my.comma.ai/', label: "Explorer", icon: "fa fa-road", priority: 1.63
      item :cabana, 'https://community.comma.ai/cabana', label: "Cabana", icon: "fa fa-bug", priority: 1.65
      item :driving_explorer, 'https://community.comma.ai/explorer.php', label: "Drive Explorer", icon: "fa fa-play", priority: 1.66
      item :slack, 'https://comma.slack.com/', icon: "fa fa-slack", priority: 1.67
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
