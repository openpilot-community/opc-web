class VehicleConfigPolicy
  attr_reader :user, :vehicle_config

  def initialize(user, vehicle_config)
    @user = user
    @vehicle_config = vehicle_config
  end
  def created?
    user.is_admin? || user.is_super_admin?
  end
  def update?
    user.is_editor? || user.is_admin? || user.is_super_admin?
  end
end