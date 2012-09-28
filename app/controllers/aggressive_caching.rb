module AggressiveCaching
  extend ActiveSupport::Concern
  included do
    before_filter :configure_caching if Rails.env.production?
  end

  def configure_caching
    last_modified = Version.current
    if ENV['REVISION'].present?
      fresh_when public: true, etag: "#{last_modified}-#{ENV['REVISION']}"
    end
    expires_in 10.seconds, public: true
  end
end
