module Scraper
  include ActiveSupport::Concern
  # before_save :scrape_image

  # def do_scrape_info
  #   update_attributes(refreshing: true)
  #   # self.refreshing = true
    
  # end

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
    
  end
end