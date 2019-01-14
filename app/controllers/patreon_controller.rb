class PatreonController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    title = "Support the Openpilot Community"
    author = "jfrux"
    imgurl = "https://www.logolynx.com/images/logolynx/58/58c8c4257c15b637b0b383edade3ea6e.png"
    linkurl = "https://opc.ai/patreon"
    @desc = "Become a Patreon supporter to opc.ai and get exclusive community perks!"
    set_meta_tags(
      title: title,
      og: {
        title: title,
        image: imgurl,
        "image:width": 1242,
        "image:height": 288,
        description: @desc,
        site_name: "Openpilot Community",
        url: linkurl,
        type: "article",
        author: author
      },
      robots: "index, follow",
      # "article:published_time": ,
      "article:publisher": "https://opc.ai/",
      "article:author":  author,
      keywords: ['support', 'patreon', 'openpilot', 'become', 'a', 'supporter'].flatten,
      description: @desc,
      canonical: linkurl,
      image_src: imgurl,
      author: author,
      twitter: {
        creator: "@#{author}",
        title: title,
        description: @desc,
        author: author
      }
    )
  end
end
