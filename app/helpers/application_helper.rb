module ApplicationHelper
  def default_meta_tags
    {
      site: "Music Hour",
      title: content_for(:title),
      reverse: true,
      charset: "utf-8",
      description: "「Music Hour」はラジオ番組へのお便りをイメージしたツールです。リスナーからのお便りを募集し、配信などで公開するためのお手伝いをします。",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        local: "ja-JP"
      },

      twitter: {
        card: "summary_large_image",
        site: "@massan_E",
        image: image_url("ogp.png")
      }
    }
  end
end
