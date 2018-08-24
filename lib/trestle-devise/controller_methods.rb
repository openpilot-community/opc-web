module Trestle
  module Auth
    module ControllerMethods
      extend ActiveSupport::Concern
      
      included do
        include Pundit
        before_action :authenticate_user!
        before_action :set_paper_trail_whodunnit
        before_action :require_edit_permissions!, only: [:new, :create, :update]
      end
      protected
      def require_edit_permissions!
        if current_user.is_visitor?
          render "unauthorized" 
          return
        end
      end
      def require_super_admin!
        unless current_user.is_super_admin?
          render "unauthorized" 
          return
        end
      end
      # def require_admin!
      #   redirect_to root_url, alert: "Only the president is authorized to access this area" unless current_user.roles?(:potus)
      # end
    end
  end
end