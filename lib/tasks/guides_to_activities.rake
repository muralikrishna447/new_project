require 'httparty'

manifest_url = 'https://www.chefsteps.com/api/v0/content_config/manifest?content_env=production'


namespace :activities do
  task :guides_to_activities, [:force] => :environment do |t, args|
    args.with_defaults(force: false)
    response = HTTParty.get(manifest_url)
    manifest = JSON.parse(response.body)

    manifest['guide'].each do |guide|
      Rails.logger.info  "Considering #{guide['title']}"

      ga = GuideActivity::create_or_update_from_guide(manifest, guide, args[:force])
      if ga
        activity = Activity.find(ga.activity_id)
        Rails.logger.info  "Output /activities/#{activity.slug}"
      else
        Rails.logger.info "No output guide"
      end

    end
    Rails.cache.clear
  end
end