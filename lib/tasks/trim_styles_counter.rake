desc 'Counter cache for vehicle config has many trim styles'

task trim_styles_counter: :environment do
  VehicleConfig.reset_column_information

  VehicleConfig.find_each(&:save)
end