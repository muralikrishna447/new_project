# Hard coded b/c I want to see absolute paths with no
base_url = "https://www.chefsteps.com"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @other_routes.each do |other|
    xml.url {
      xml.loc("#{base_url}#{other}")
      xml.changefreq("daily")
      xml.priority(1)
      # Assume our primary pages and landing pages are updated today
      xml.lastmod(Time.now.xmlschema)
    }
  end
  @main_stuff.each do |p|
    xml.url {
      if p.is_a?(Assembly) && p.assembly_type == "Course"
        xml.loc(base_url + landing_class_path(p))
      elsif p.is_a?(Page)
        # Use shorter root url for pages
        xml.loc(base_url + '/' + p.slug)
      else
        xml.loc(base_url + url_for(p))
      end
      # Put the highest priority on ChefSteps activities
      if p.is_a?(Activity) && ! p.user
        xml.priority(1)
      end
      xml.changefreq("daily")
      # Can't just use updated_at because comments aren't include, so
      # do more recent of updated_at or 1 month
      xml.lastmod([p.updated_at, 1.month.ago].max.xmlschema)
    }
  end
end