# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/videos"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/maps"
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/fonts"

# Rails.application.config.assets.css_compressor = :yui
Rails.application.config.assets.js_compressor = :uglifier

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile +=  %w(print.css)
