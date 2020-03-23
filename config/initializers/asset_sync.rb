require 'asset_sync'

# Later versions of the asset sync gem have a config setting to
# disable sync on precompile, which would be ideal, but this does the trick.
AssetSync.configure do |config|
  config.enabled = false if ENV['ASSET_SYNC_ENABLED'] == 'false'
end
