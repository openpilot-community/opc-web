Trestle.admin(:vehicles, model: VehicleConfig) do
  form do |vehicle_config|
    row do
      col(sm: 3, class: "year-range") do
        row do
          col(sm: 6, class: "year-start") { select :year, 2010..(Time.zone.now.year + 2) }
          col(sm: 6, class: "year-end") { select :year_end, 2010..(Time.zone.now.year + 2), label: nil }
        end
      end
      col(sm: 4) { collection_select :vehicle_make_id, VehicleMake.order(:name), :id, :name, include_blank: true }
      col(sm: 5) { collection_select :vehicle_model_id, vehicle_config.vehicle_make.blank? ? [] : vehicle_config.vehicle_make.vehicle_models.order(:name), :id, :name, include_blank: true }
      # col(sm: 5) do
      #   select :vehicle_trim_ids, (vehicle_config.vehicle_model.blank? ? [] : VehicleTrim.where(:vehicle_model => vehicle_config.vehicle_model.id).order(:name)), { label: "Trim(s)" }, { multiple: true, data: { tags: true } }
      #   # tag_select :vehicle_config_trim_styles
      # end
    end
  end

  controller do
    skip_before_action :authenticate_user!
    before_action :set_resources
    layout "documentation"
    def index
      @makes = VehicleMake.with_configs
    end
    def create

    end
    def lookup
      @vehicle_config = VehicleConfig.new
      # @makes = VehicleMake.with_configs
      # trestle_form_for(@vehicle_config, url: admin.instance_path(@vehicle_config, action: :update)) do |f|
      #   f.text_field :year
      # end
    end
    
    def set_resources
      if !params['make_slug'].blank?
        @make = VehicleMake.friendly.find(params['make_slug'])
      end
      if !params['model_slug'].blank?
        @model = VehicleModel.friendly.find(params['model_slug'])
      end
    end

    def make
      
    end

    def model
      
    end

    def show
      @config = VehicleConfig.friendly.find(params['config_slug'])
      @make = @config.vehicle_make
      @model = @config.vehicle_model
    end

    def show_trim
      @trim = VehicleTrimStyle.find(params['trim_style_id'])
      @config = VehicleConfig.friendly.find(params['config_slug'])
      @make = @config.vehicle_make
      @model = @config.vehicle_model
    end
  end

  routes do
    post 'create', to: 'vehicles_admin/admin#create', as: 'vehicles_admin_create'
    get 'index', to: 'vehicles_admin/admin#index', as: 'vehicles_admin_index'
    get 'lookup', to: 'vehicles_admin/admin#lookup', as: 'vehicles_admin_lookup'
    get 'm/:make_slug', to: 'vehicles_admin/admin#make', as: 'vehicles_admin_make'
    get 'm/:make_slug/:model_slug', to: 'vehicles_admin/admin#model', as: 'vehicles_admin_model'
    get ':config_slug', to: 'vehicles_admin/admin#show', as: 'vehicles_admin_show'
    get ':config_slug/:trim_style_id', to: 'vehicles_admin/admin#show_trim', as: 'vehicles_admin_show_trim'
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
