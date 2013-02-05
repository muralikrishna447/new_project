base_url = "http://#{request.host_with_port}"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @other_routes.each do |other|
    xml.url {
      xml.loc("http://chefsteps.com#{other}")
      xml.changefreq("daily")
    }
  end
  @courses.each do |p|
    xml.url {
      xml.loc(course_url(p))
      xml.changefreq("daily")
    }
  end
  @activities.each do |p|
    xml.url {
      xml.loc(activity_url(p))
      xml.changefreq("daily")
    }
  end
end