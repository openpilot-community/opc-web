class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def discord
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @identity = Identity.from_omniauth(request.env["omniauth.auth"])
    if @identity.persisted?
      sign_in @identity.user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
      
      redirect_to after_sign_in_path_for(@identity.user)
    else
      session["devise.discord_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  def github
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end