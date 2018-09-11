module Trestle
  module Auth
    module ControllerMethods
      extend ActiveSupport::Concern
      
      included do
        # include Pundit
        include ActionView::Helpers::AssetUrlHelper
        before_action :set_raven_context
        before_action :authenticate_user!, except: [:show, :index]
        before_action :set_paper_trail_whodunnit
        before_action :require_edit_permissions!, only: [:new, :create, :update, :destroy]
        before_action :set_metatags
        before_action :clear_current_user_state
        helper_method :current_user_state
        
        def clear_current_user_state
          session[:current_user_state] = nil
        end

        def current_user_state
          if current_user.present?
            if session[:current_user_state].present?
              session[:current_user_state]
            else
              session[:current_user_state] = {
                following: current_user.followees(VehicleConfig).map(&:id)
              }
            end
          else
            {
              following: []
            }
          end
        end

        def current_or_guest_user
          if current_user.present?
            current_user
          else
            nil
          end
        end
        private

        def set_raven_context
          if Rails.env.production?
            Raven.user_context(id: session[:current_user_id]) # or anything else in session
            Raven.extra_context(params: params.to_unsafe_h, url: request.url)
          end
        end
      end

      protected
      def set_metatags
        set_meta_tags og: {
          title: "Openpilot Database",
          image: asset_url("/assets/og/default.png"),
          type: "website"
        }
        set_meta_tags keywords: ['openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility']
        set_meta_tags description: "The goal of this is to be a community resource and centralized location for knowledge on Openpilot Vehicles"
      end
      def require_edit_permissions!
        if !current_or_guest_user.is_visitor? && !current_or_guest_user.is_admin? && !current_or_guest_user.is_super_admin?
          render "unauthorized" 
          return
        end
      end

      def require_super_admin!
        unless current_or_guest_user.is_super_admin?
          render "unauthorized" 
          return
        end
      end
    end
  end
end