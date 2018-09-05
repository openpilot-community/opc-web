class DownloadImageFromSourceWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3 # Only five retries and then to the Dead Job Queue

  def perform(objid,klass)
    obj = klass.constantize.find(objid)
    puts obj.to_yaml
    if obj.present?
      if obj.source_image_url.present?
        tempfile = Down.download(obj.source_image_url)
        
        obj.image.attach(
          io: tempfile,
          filename: "#{obj.slug}.#{tempfile.original_filename}",
          content_type: tempfile.content_type
        )

        obj.save
      end
    end
  end
end