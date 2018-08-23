class VehicleConfigVehicleTrim < ApplicationRecord
  self.table_name = "vehicle_config_trims"
  belongs_to :vehicle_config
  belongs_to :vehicle_trim
end