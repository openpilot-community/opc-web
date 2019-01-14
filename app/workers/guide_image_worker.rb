class GuideImageWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3 # Only five retries and then to the Dead Job Queue

  def perform(guide_id)
    guide_image = GuideImage.constantize.new(:guide_id => guide_id)
    # puts obj.to_yaml
    if guide_image.present?
      if guide_image.source_image_url.present?
        tempfile = Down.download(obj.source_image_url)
        
        guide_image.image.attach(
          io: tempfile,
          filename: "#{guide_image.slug}.#{tempfile.original_filename}",
          content_type: tempfile.content_type
        )

        guide_image.save
      end
    end
  end
end