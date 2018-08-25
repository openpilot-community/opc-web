module Trestle
  module Auth
    module ControllerMethods
      extend ActiveSupport::Concern
      
      included do
        include Pundit
        before_action :authenticate_user!, except: [:show, :index]
        before_action :set_paper_trail_whodunnit
        before_action :require_super_admin!, only: [:destroy]
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
    end
  end
end