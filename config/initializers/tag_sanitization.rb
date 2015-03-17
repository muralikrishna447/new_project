class TagSanitizationParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      if @tag_list.is_a?(Array)
        tag_list.add @tag_list.map{|s| Sanitize.fragment(s, Sanitize::Config.merge(Sanitize::Config::RELAXED, remove_contents: true)) }
      else
        tag_list.add @tag_list.split(',').map{&:strip).map{|s| Sanitize.fragment(s, Sanitize::Config.merge(Sanitize::Config::RELAXED, remove_contents: true)) }
      end
    end
  end
end

ActsAsTaggableOn.default_parser = TagSanitizationParser
