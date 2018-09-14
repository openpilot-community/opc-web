class SitemapController < ApplicationController

  def index
    @pages = ['', 'about.html', 'contacts.html']

    # @products = Product.all

    respond_to do |format|
      format.xml
    end
  end

end
