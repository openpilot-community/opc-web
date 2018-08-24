module Trestle
  module Auth
    module ControllerMethods
      extend ActiveSupport::Concern

      included do
        include Pundit
        before_action :authenticate_user!
        before_action :set_paper_trail_whodunnit
        # before_action :require_president!
      end

      protected

      # def require_admin!
      #   redirect_to root_url, alert: "Only the president is authorized to access this area" unless current_user.roles?(:potus)
      # end
    end
  end
end