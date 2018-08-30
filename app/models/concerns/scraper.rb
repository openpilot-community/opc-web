module Scraper
  include ActiveSupport::Concern
  # before_save :scrape_image

  def do_scrape_info
    update_attributes(refreshing: true)
    # self.refreshing = true
    save!
    self.delay.scrape_info
  end

  def scrape_image
    # begin
      if !self.image.attached?
        make_name_parameter = vehicle_make.name.parameterize(separator: '_').downcase
        model_name_parameter = vehicle_model.name.gsub('-',' ').parameterize(separator: '_').downcase
        model_parameter = "#{make_name_parameter}-#{model_name_parameter}-#{year}"
        trim_info = Cars::Vehicle.retrieve("#{model_parameter}/trims")
        image_url = trim_info[:image]
        tempfile = Down.download(image_url)
        
        self.image.attach(
          io: tempfile,
          filename: "#{slug}.#{tempfile.original_filename}",
          content_type: tempfile.content_type
        )
      end
    # rescue
    #   puts "Failed to scrape image"
    # end
  end

  def scrape_info
    if !image.attached?
      scrape_image
    end
    year_range = year_range || [year]

    begin
      year_range.each do |curr_year|
        trims = []
        
        make_name_parameter = vehicle_make.name.parameterize(separator: '_').downcase
        model_name_parameter = vehicle_model.name.gsub('-',' ').parameterize(separator: '_').downcase
        model_parameter = "#{make_name_parameter}-#{model_name_parameter}-#{curr_year}"

        trim_info = Cars::Vehicle.retrieve("#{model_parameter}/trims")
        trims = trim_info[:trims]
        # first_trim = trim_info[:trims].first
        
        trims.each_with_index do |trim, index|
          vehicle_trim = VehicleTrim.find_or_initialize_by(name: trim.name, year: curr_year, vehicle_model: self.vehicle_model)
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
      self.refreshing = false
      save!
    rescue
      self.refreshing = false
      save!
    end
  end
end