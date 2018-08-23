# == Schema Information
#
# Table name: vehicle_trims
#
#  id                              :bigint(8)        not null, primary key
#  vehicle_make_id                 :bigint(8)
#  vehicle_model_id                :bigint(8)
#  make_id                         :string
#  make_display                    :string
#  name                            :string
#  trim                            :string
#  year                            :string
#  body                            :string
#  engine_position                 :string
#  engine_cc                       :integer
#  engine_cyl                      :integer
#  engine_type                     :string
#  engine_valves_per_cyl           :integer
#  engine_power_ps                 :string
#  engine_power_rpm                :integer
#  engine_torque_nm                :string
#  engine_torque_rpm               :integer
#  engine_bore_mm                  :float
#  engine_stroke_mm                :float
#  engine_compression              :string
#  engine_fuel                     :string
#  top_speed_kph                   :integer
#  zero_to_100_kph                 :integer
#  drive                           :string
#  drive2                          :string
#  seats                           :integer
#  seats2                          :integer
#  weight_kg                       :integer
#  length_mm                       :float
#  width_mm                        :float
#  height_mm                       :float
#  wheelbase_mm                    :float
#  lkm_hwy                         :float
#  lkm_mixed                       :float
#  lkm_city                        :float
#  fuel_cap_l                      :integer
#  sold_in_us                      :boolean
#  co2                             :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  forward_collision_warning       :integer
#  adaptive_cruise_control         :integer
#  lane_departure_warning          :integer
#  lane_keeping_assist             :integer
#  blind_spot_warning              :integer
#  rear_cross_traffic_alert        :integer
#  back_up_camera                  :integer
#  adaptive_headlights             :integer
#  antilock_braking_system         :integer
#  automatic_emergency_braking     :integer
#  automatic_parallel_parking      :integer
#  backup_warning                  :integer
#  biycle_detection                :integer
#  blind_spot_monitoring           :integer
#  brake_assist                    :integer
#  curve_speed_warning             :integer
#  drowsiness_alert                :integer
#  electronic_stability_control    :integer
#  high_speed_alert                :integer
#  hill_descent_assist             :integer
#  hill_start_assist               :integer
#  left_turn_crash_avoidance       :integer
#  pedestrian_detection            :integer
#  push_button_start               :integer
#  sideview_camera                 :integer
#  temperature_warning             :integer
#  tire_pressure_monitoring_system :integer
#  traction_control                :integer
#  obstacle_detection              :integer
#

class VehicleSpec < ApplicationRecord
  has_paper_trail
  # before_save :set_name
  belongs_to :vehicle_make, :optional => true
  belongs_to :vehicle_model, :optional => true
  belongs_to :forward_collision_warning, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :adaptive_cruise_control, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :lane_departure_warning, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :lane_keeping_assist, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :blind_spot_warning, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :rear_cross_traffic_alert, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :back_up_camera, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :adaptive_headlights, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :antilock_braking_system, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :automatic_emergency_braking, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :automatic_parallel_parking, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :backup_warning, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :biycle_detection, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :blind_spot_monitoring, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :brake_assist, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :curve_speed_warning, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :drowsiness_alert, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :electronic_stability_control, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :high_speed_alert, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :hill_descent_assist, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :hill_start_assist, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :left_turn_crash_avoidance, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :pedestrian_detection, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :push_button_start, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :sideview_camera, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :temperature_warning, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :tire_pressure_monitoring_system, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :traction_control, :class_name => "VehicleOptionAvailability", :optional => true
  belongs_to :obstacle_detection, :class_name => "VehicleOptionAvailability", :optional => true

  def name
    "#{trim}"
  end
  # def make_name
  #   vehicle_make.name
  # end

  # def model_name
  #   vehicle_model.name
  # end
  # private
  # def set_name
  #   loop do
  #     self.name = "#{year} #{make.name} #{model.name} #{trim}"
  #     break unless VehicleMake.where().exists?
  #   end
  # end
end
