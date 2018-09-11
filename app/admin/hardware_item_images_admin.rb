Trestle.resource(:hardware_item_images) do
  
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
    skip_before_action :require_edit_permissions!
    skip_before_action :require_super_admin!
    
    # before_action :set_current_user, only: ['create','update']
    def create
      self.instance = admin.build_instance(permitted_params, params)
      self.instance.hardware_item_id = params['hardware_item_id']
      self.instance.image.name = permitted_params['image_attributes']['attachment'].original_filename
      
      if admin.save_instance(instance)
        respond_to do |format|
          format.html do
            flash[:message] = flash_message("create.success", title: "Success!", message: "The %{lowercase_model_name} was successfully created.")
            redirect_to_return_location(:create, instance, default: admin.instance_path(instance))
          end
          format.json { render json: instance, status: :created, location: admin.instance_path(instance) }
          format.js
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:error] = flash_message("create.failure", title: "Warning!", message: "Please correct the errors below.")
            render "new", status: :unprocessable_entity
          end
          format.json { render json: instance.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end
  end

  form(dialog:true) do |hardware_item_image|
    collection_select :hardware_item_id, HardwareItem.order(:title), :id, :title, include_blank: true
    collection_select :image_id, Image.order(:name), :id, :name, include_blank: true
    fields_for :image, hardware_item_image.image || hardware_item_image.build_image do
      # Form helper methods now dispatch to the product.category form scope
      file_field :attachment
      # select :hardware_item_ids, HardwareItem.all.order(:name), {label: "Tag hardware in this guide"}, {prompt: "Choose an existing guide"}, { multiple: true, data: { tags: true } }
      # hidden_field :user_id, :value => current_user.id
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
  #   params.require(:hardware_item_image).permit(:name, ...)
  # end
end
