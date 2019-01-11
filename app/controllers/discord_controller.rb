class DiscordController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    title = "Join the Comma.ai Community Discord!"
    author = "jfrux"
    imgurl = "https://discordapp.com/assets/e7a3b51fdac2aa5ec71975d257d5c405.png"
    linkurl = "https://opc.ai/workbench"
    @desc = "Comma.ai is now on Discord, we welcome you to get an account and join up today!"
    set_meta_tags(
      title: title,
      og: {
        title: title,
        image: imgurl,
        "image:width": 2482,
        "image:height": 1534,
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
      keywords: ['download', 'discord', 'openpilot', 'join', 'comma.ai'].flatten,
      description: @desc,
      canonical: linkurl,
      image_src: imgurl,
      author: author,
      twitter: {
        creator: "@#{author}",
        title: title,
        # card: "summary-large",
        description: @desc,
        author: author
      }
    )
  end
end
