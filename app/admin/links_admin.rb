Trestle.admin(:links) do
  menu do
    group :useful_tools, priority: 400 do
      item :slack, 'https://comma.slack.com/', icon: "fa fa-slack"
      item :cabana, 'https://community.comma.ai/cabana', icon: "fa fa-bug"
      item :explorer, 'https://my.comma.ai/', icon: "fa fa-play"
    end
  end
end
