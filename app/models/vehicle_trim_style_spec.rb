class VehicleTrimStyleSpec < ApplicationRecord
  # default_scope{ order(:name) }
  belongs_to :vehicle_trim_style
  
end
