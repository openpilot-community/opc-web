Trestle.resource(:pull_requests) do
  menu do
    item :pull_requests, icon: "fa fa-github", group: :development
  end
  scope :all, -> { PullRequest.order(:pr_updated_at => :desc) }, default: true
  
  # Customize the table columns shown on the index view.
  #
  table do
    column :name, header: "Title" do |pull_request|
      link_to pull_request.html_url, target: "_blank" do
        pull_request.name
      end
    end
    column :vehicles
    column :status do |pull_request|
      pull_request.state
    end
    column :user do |pull_request|
      pull_request.user
    end
    column :pr_updated_at, header: "Created"
    column :pr_created_at, header: "Updated"

    # column :body do |pull_request|
    #   pull_request.body
    # end
  end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |pull_request|
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
  #   params.require(:pull_request).permit(:name, ...)
  # end
end
