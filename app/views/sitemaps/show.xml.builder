base_url = "http://#{request.host_with_port}"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @other_routes.each do |other|
    xml.url {
      xml.loc("http://chefsteps.com#{other}")
      xml.changefreq("daily")
    }
  end
  @main_stuff.each do |p|
    xml.url {
      if p.is_a?(Assembly) && p.assembly_type == "Course"
        xml.loc(landing_class_path(p))
      elsif p.is_a?(Assembly) && p.assembly_type == "Project"
        xml.loc(project_path(p))
      else
        xml.loc(url_for(p))
      end
      xml.changefreq("daily")
    }
  end
end