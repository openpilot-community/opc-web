Trestle.admin(:docs) do

  controller do
    skip_before_action :authenticate_user!
    before_action :set_resources
    layout "documentation"
    def index
      @makes = VehicleMake.with_configs
    end
    def create

    end
    
    def set_resources
      @trims = []

      if !params['year'].blank?
        @year = params['year']
      end

      if !params['config_slug'].blank?
        @config = VehicleConfig.friendly.find(params['config_slug'])
        if !params['year'].blank? && @trims.blank?
          @trims = @config.trim_styles
        end
      end
      
      if @config.present?
        @make = @config.vehicle_make
        @model = @config.vehicle_model
        @trims = @config.trim_styles
      else
        if !params['make_slug'].blank?
          @make = VehicleMake.friendly.find(params['make_slug'])
        end

        if !params['model_slug'].blank?
          @model = VehicleModel.friendly.find(params['model_slug'])
          if @year && @trims.blank?
            @trims = @model.trim_styles(@year)
          end
        end
      end

      @config = VehicleConfig.find_by_ymm(@year,@make.id,@model.id)
      if @config.blank? && @model.present? && @year.present?
        if !@model.image.attached?
          @model.scrape_image(nil,@year)
          @model.save!
        end
        @image = @model.image
      else
        if @config.present? && @config.image.attached?
          @image = @config.image
        end
      end
      if @image.blank? && @config.present?
        @image = @config.image
      end
      @title = "#{@year} #{@make.name} #{@model.name}"
    end

    def make
      
    end

    def model
      
    end

    def show
      if @config.present?
        @make = @config.vehicle_make
        @model = @config.vehicle_model
      else

      end
    end

    def show_trim
      @trim = VehicleTrimStyle.find(params['trim_style_id'])
      @config = VehicleConfig.find_by_ymm(@year,@make.id,@model.id)
      # @make = @config.vehicle_make
      # @model = @config.vehicle_model
    end
  end

  routes do
    post 'create', to: 'vehicles_admin/admin#create', as: 'vehicles_admin_create'
    get 'index', to: 'vehicles_admin/admin#index', as: 'vehicles_admin_index'
    get 'm/:make_slug', to: 'vehicles_admin/admin#make', as: 'vehicles_admin_make'
    get 'm/:make_slug/:model_slug', to: 'vehicles_admin/admin#model', as: 'vehicles_admin_model'
    get 'm/:make_slug/:model_slug/:year', to: 'vehicles_admin/admin#show', as: 'vehicles_admin_show_year'
    get 'm/:make_slug/:model_slug/:year/:trim_style_id', to: 'vehicles_admin/admin#show_trim', as: 'vehicles_admin_show_year_trim'
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
