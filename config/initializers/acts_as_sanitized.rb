module ActsAsSanitized
  extend ActiveSupport::Concern

  included do
    attr_accessor :bypass_sanitization
  end

  module ActiveRecordExtension
    def sanitize_input(*args)
      before_validation do
        unless defined?(self.bypass_sanitization) && self.bypass_sanitization == true # Doing an actual comparison to true so that it can't be truthy it has to be true.
          args.each do |field|
            self[field] = Sanitize.fragment(self[field], Sanitize::Config.merge(Sanitize::Config::RELAXED, remove_contents: true))
            self[field] = if self[field].kind_of?(String) && self[field].match(/\{{/) && self[field].match(/\}}/)
                            self[field].gsub(/\{{|\}}/, '')
                          else
                            self[field]
                          end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.extend(ActsAsSanitized::ActiveRecordExtension)
