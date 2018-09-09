class CabanaLink < ApplicationRecord
  before_save :parse_url
  
  def parse_url
    share_url_parsed = URI.parse(source_cabana_url)
    params = CGI::parse(share_url_parsed.query)
    self.segment_url = URI.parse(params.url)
    self.route_id = params.route.split("|").first
    self.route_segment = params.route.split("|").last
  end
end
