class ApplicationController < ActionController::Base
  # before_action :set_raven_context
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new_session_path(scope)
    new_user_session_path
  end

  private

  # def set_raven_context
  #   if Rails.env.production?
  #     Raven.user_context(id: session[:current_user_id]) # or anything else in session
  #     Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  #   end
  # end
end
