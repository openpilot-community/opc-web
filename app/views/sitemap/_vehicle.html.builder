items.each do |item|
  xml.url do
    xml.loc product_path(item)
  end

end