module Trestle
  module Auth
    module ControllerMethods
      extend ActiveSupport::Concern
      
      included do
        # include Pundit
        include ActionView::Helpers::AssetUrlHelper
        before_action :authenticate_user!, except: [:show, :index]
        before_action :set_paper_trail_whodunnit
        before_action :require_super_admin!, only: [:destroy]
        before_action :require_edit_permissions!, only: [:new, :create, :update]
        before_action :set_metatags
 
        def current_or_guest_user
          if current_user.present?
            current_user
          else
            nil
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