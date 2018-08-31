class ScrapeCarsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3 # Only five retries and then to the Dead Job Queue

  def perform(vcid)
    vc = VehicleConfig.find(vcid)
    if vc.present?
      if !vc.image.attached?
        year = vc.year_range.last
        make_name_parameter = vc.vehicle_make.name.parameterize(separator: '_').downcase
        model_name_parameter = vc.vehicle_model.name.gsub('-',' ').parameterize(separator: '_').downcase
        model_parameter = "#{make_name_parameter}-#{model_name_parameter}-#{year}"
        trim_info = Cars::Vehicle.retrieve("#{model_parameter}/trims")
        image_url = trim_info[:image]
        tempfile = Down.download(image_url)
        
        vc.image.attach(
          io: tempfile,
          filename: "#{slug}.#{tempfile.original_filename}",
          content_type: tempfile.content_type
        )
      end
    end
  end
end