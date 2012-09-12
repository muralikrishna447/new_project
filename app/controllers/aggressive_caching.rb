module AggressiveCaching
  extend ActiveSupport::Concern
  included do
    before_filter :configure_caching if Rails.env.production? || Rails.env.staging?
  end

  def configure_caching
    last_modified = File.mtime("#{Rails.root}/.bundle")
    fresh_when last_modified: last_modified, public: true, etag: last_modified
    expires_in 10.seconds, public: true
  end
end
