class TagSanitizationParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      tag_list.add @tag_list.map{|s| Sanitize.fragment(s, Sanitize::Config.merge(Sanitize::Config::RELAXED, remove_contents: true)) }
    end
  end
end

ActsAsTaggableOn.default_parser = TagSanitizationParser
