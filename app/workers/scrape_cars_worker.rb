class ScrapeCarsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3 # Only five retries and then to the Dead Job Queue
  def perform(vcid)
    vc = VehicleConfig.find(vcid)
    if vc.present?
      year_range = vc.year_range
      
      # begin
        year_range.each do |curr_year|
          trims = []
          
          make_name_parameter = vc.vehicle_make.name.parameterize(separator: '_').downcase
          model_name_parameter = vc.vehicle_model.name.gsub('-',' ').parameterize(separator: '_').downcase
          model_parameter = "#{make_name_parameter}-#{model_name_parameter}-#{curr_year}"
          
          trim_info = Cars::Vehicle.retrieve("#{model_parameter}/trims")
          trims = trim_info[:trims]
          # first_trim = trim_info[:trims].first
          
          trims.each_with_index do |trim, index|
            vehicle_trim = VehicleTrim.find_or_initialize_by(name: trim.name, year: curr_year, vehicle_model: vc.vehicle_model)
            vehicle_trim.sort_order = index
            vehicle_trim.save
            
            trim[:styles].each do |style|
              new_style = vehicle_trim.vehicle_trim_styles.find_or_initialize_by(:name => style[:name])
              new_style.inventory_prices = style[:inventory_prices]
              new_style.mpg = style[:mpg]
              new_style.engine = style[:engine]
              new_style.trans = style[:trans]
              new_style.drive = style[:drive]
              new_style.colors = style[:colors]
              new_style.seats = style[:seats]
              new_style.save!
              
              if !new_style.has_specs?
                # begin
                  specs = Cars::VehicleStyle.retrieve(style[:link].gsub("#{ENV['VEHICLE_ROOT_URL']}/",''))[:specs]
                  specs.each do |spec|
                    new_spec = new_style.vehicle_trim_style_specs.find_or_initialize_by(:name => spec[:name])
                    new_spec.value = spec[:value]
                    new_spec.group = spec[:type]
                    new_spec.inclusion = spec[:inclusion]
                    new_spec.save!
                  end
                # rescue Exception => e
                #   throw "Could not fetch specs for #{vehicle_trim.name} #{new_style.name} due to #{e.message}."
                # end
              end
            end
          end
        end
        vc.update_attributes(refreshing: false)
      # rescue
      #   vc.update_attributes(refreshing: false)
      # end
    end
  end
end