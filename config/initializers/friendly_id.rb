FriendlyId.defaults do |config|
  config.base = :name_for_slug
  config.use :slugged
  config.use :history
end
