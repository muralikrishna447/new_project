require 'json'

# There is a bug in the ActiveSupport JSON encoder that chokes on
# emoji chars.  This patch was accepted into mainline for the Rails
# 4.0 release (although it may have since been refactored)
#
# See: https://github.com/rails/rails/commit/8f8397e0a4ea2bbc27d4bba60088286217314807
module ActiveSupport::JSON::Encoding
  class << self
    def escape(string)
      if string.respond_to?(:force_encoding)
        string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
      end
      json = string.gsub(escape_regex) { |s| ESCAPED_CHARS[s] }
      json = %("#{json}")
      json.force_encoding(::Encoding::UTF_8) if json.respond_to?(:force_encoding)
      json
    end
  end
end
