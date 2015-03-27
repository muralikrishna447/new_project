# Hard coded b/c I want to see absolute paths with no
base_url = "http://www.chefsteps.com"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @other_routes.each do |other|
    xml.url {
      xml.loc("#{base_url}#{other}")
      xml.changefreq("daily")
    }
  end
  @main_stuff.each do |p|
    xml.url {
      if p.is_a?(Assembly) && p.assembly_type == "Course"
        xml.loc(base_url + landing_class_path(p))
      elsif p.is_a?(Assembly) && p.assembly_type == "Project"
        xml.loc(base_url + project_path(p))
      else
        xml.loc(base_url + url_for(p))
      end
      # Put the highest priority on ChefSteps activities
      if p.is_a?(Activity) && ! p.creator
        xml.priority(1)
      end
      xml.changefreq("daily")
    }
  end
end