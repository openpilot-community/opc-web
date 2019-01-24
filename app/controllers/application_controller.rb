class ApplicationController < ActionController::Base
  before_action :set_raven_context
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new_session_path(scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end
  private
  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an 
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
  end
  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end
  def set_raven_context
    if Rails.env.production?
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
  end
end
