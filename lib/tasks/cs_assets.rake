require 'asset_sync'

namespace :cs_assets do
  # Later versions of asset_sync come with a task that does this,
  # our ancient version does not.
  desc "Syncs precompiled assets to S3"
  task :sync => :environment do
    AssetSync.sync
  end
end
