require 'httparty'

manifest_url = 'https://www.chefsteps.com/api/v0/content_config/manifest?content_env=production'


namespace :activities do
  task :guides_to_activities, [:force] => :environment do |t, args|
    args.with_defaults(force: false)
    response = HTTParty.get(manifest_url)
    manifest = JSON.parse(response.body)

    manifest['guide'].each do |guide|
      next unless guide['slug'] == 'creme-brulee-guide'
      puts "------ Considering #{guide['title']}"


      ga = GuideActivity::create_or_update_from_guide(manifest, guide, args[:force])
      if ga
        activity = Activity.find(ga.activity_id)
        puts "------ Output http://localhost:3000/activities/#{activity.slug}"
      else
        puts "------ No output guide"
      end

    end
    Rails.cache.clear
  end
end