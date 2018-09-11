Trestle.resource(:images) do

  controller do
    skip_before_action :require_edit_permissions!
    skip_before_action :require_super_admin!
    def create
      self.instance = admin.build_instance(permitted_params, params)
      # self.instance = Image.create! file: params[:attachment]
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
  # Customize the table columns shown on the index view.
  #
  table do
    column :attachment
    column :created_at, align: :center
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form(dialog: true) do |image|
    if image.attachment.attached?
      render inline: image_tag(image.attachment.service_url)
    end
    file_field :attachment
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:image).permit(:name, ...)
  # end
end
