Trestle.resource(:vehicle_trim_styles) do
  # menu do
  #   item :vehicle_trim_styles, icon: "fa fa-star"
  # end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  controller do
    def index
      # byebug
      if !params['trim'].blank?
        selected_trim = VehicleTrim.find(params['trim'])
        
        if selected_trim.blank?
          return
        end
        collection = selected_trim.vehicle_trim_styles
      end
      respond_to do |format|
        format.html
        format.json { render json: collection }
        format.js
      end
    end
  end
  form(dialog: true) do |vehicle_trim_style|
    tab :general do
      text_field :name
      text_field :inventory_prices
      text_field :mpg
      text_field :engine
      text_field :trans
      text_field :drive
      text_field :colors
      text_field :seats
    end
    tab :specs do
      table vehicle_trim_style.vehicle_trim_style_specs.blank? ? [] : vehicle_trim_style.vehicle_trim_style_specs, admin: :vehicle_trim_style_specs do
        # column :id
        column :group
        column :name
        column :value
        column :inclusion
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
  #   params.require(:vehicle_trim_style).permit(:name, ...)
  # end
end
