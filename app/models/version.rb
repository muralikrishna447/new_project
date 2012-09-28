class Version < ActiveRecord::Base
  attr_accessible :version, as: :admin
  after_update :purge_cache

  def self.current
    Rails.cache.fetch("version") { Version.first.updated_at }
  end

  def purge_cache
    Rails.cache.delete 'version'
  end
end
