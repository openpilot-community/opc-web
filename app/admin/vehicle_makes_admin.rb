Trestle.resource(:vehicle_makes) do
  menu do
    item :vehicle_makes, icon: "fa fa-car", group: :admin, label: "Makes"
  end

  # Customize the table columns shown on the index view.
  #
  table do
    column :name, link: true
    column :active_count, header: "Active Models"
    column :inactive_count, header: "Inactive Models"
    column :slack_channel, header: "Comma Slack" do |make|
      if make.slack_channel
        "<a href=\"slack://channel?team=comma&id=#{make.slack_channel}\">##{make.slack_channel}</a>".html_safe
      end
    end
  end
  
  search do |query|
    if query
      VehicleMake.where("name ILIKE ?", "%#{query}%")
    else
      VehicleMake.all
    end
  end
  # Customize the form fields shown on the new/edit views.
  #
  form(dialog: true) do |vehicle_make|
    
  end

  form do |vehicle_make|
    tab :general do
      text_field :name
      text_field :slack_channel
    end

    unless vehicle_make.new_record?
      tab :models, badge: vehicle_make.vehicle_models.blank? ? nil : vehicle_make.vehicle_models.size do
        render "tab_toolbar", {
          :groups => [
            {
              :class => 'filters pull-left',
              :items => [
                link_to("Active (#{vehicle_make.active_count})", "?filter=active#!tab-models", class: params[:filter] == "active" ? "btn btn-default btn-list-add active" : "btn btn-default btn-list-add"),
                link_to("Inactive (#{vehicle_make.inactive_count})", "?filter=inactive#!tab-models", class: params[:filter] == "inactive" ? "btn btn-default btn-list-add active" : "btn btn-default btn-list-add")
              ]
            },
            {
              :class => "actions pull-right",
              :items => [
                admin_link_to("Add Model", admin: :vehicle_models, action: :new, class: "btn btn-default btn-list-add", params: { vehicle_make_id: vehicle_make.blank? ? nil : vehicle_make.id })
              ]
            }
          ]
        }
        
        table vehicle_make.vehicle_models.blank? ? [] : vehicle_make.vehicle_models.where(:status => (params[:filter] == 'inactive') ? 0 : 1).order(:name), admin: :vehicle_models do
          column :name
          column :status
        end
      end
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
  #   params.require(:vehicle_make).permit(:name, ...)
  # end
end
