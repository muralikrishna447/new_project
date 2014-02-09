module PageHelper
  def landing_page_content(course)
    case course.slug
    when "whipping-siphons"
      Page.where(slug: "whipping-siphons-free-trial").first.content.html_safe
    when "french-macarons"
      Page.where(slug: "french-macarons-free-trial").first.content.html_safe
    else
      Page.where(slug: "whipping-siphons-free-trial").first.content.html_safe
    end
  end
end