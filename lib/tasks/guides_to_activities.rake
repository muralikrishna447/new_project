require 'httparty'

manifest_url = 'https://www.chefsteps.com/api/v0/content_config/manifest?content_env=production'


namespace :activities do
  task :guides_to_activities, [:force,:only] => :environment do |t, args|
    args.with_defaults(force: false)
    response = HTTParty.get(manifest_url)
    manifest = JSON.parse(response.body)
    pub_date = DateTime.now

    manifest['guide'].each do |guide|
      next if args[:only] && ! guide['title'].starts_with?(args[:only])

      Rails.logger.info  "Considering #{guide['title']}"

      ga = GuideActivity::create_or_update_from_guide(manifest, guide, args[:force])
      if ga
        activity = Activity.find(ga.activity_id)
        Rails.logger.info  "Output /activities/#{activity.slug}"

      else
        Rails.logger.info "No output guide"
      end

    end

  end
end
