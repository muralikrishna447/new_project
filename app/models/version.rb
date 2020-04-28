class Version < ActiveRecord::Base

  after_update :purge_cache

  def self.current
    Rails.cache.fetch("version") do
      version = Version.first
      version && version.updated_at
    end
  end

  def purge_cache
    Rails.cache.delete 'version'
    puts "Version was purged."
  end
end
