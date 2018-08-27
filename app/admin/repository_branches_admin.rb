Trestle.resource(:repository_branches) do
  # menu do
    # item :repository_branches, icon: "fa fa-star", :group =>
  # end
  controller do
    def index
      # byebug
      if !params['repository'].blank?
        collection = RepositoryBranch.where(repository: Repository.find(params['repository'].to_i))
      end
      respond_to do |format|
        format.html
        format.json { render json: collection }
        format.js
      end
    end
    def get_by_repository
      RepositoryBranch.where(:repository => params['repository']).to_json
    end
  end
  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |repository_branch|
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
  #   params.require(:repository_branch).permit(:name, ...)
  # end
end
