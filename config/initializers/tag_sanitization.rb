class TagSanitizationParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      tag_list.add Sanitize.fragment(@tag_list).split(',')
    end
  end
end

ActsAsTaggableOn.default_parser = TagSanitizationParser
