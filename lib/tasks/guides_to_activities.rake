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
        if ! activity.published
          activity.published = true
          activity.published_at = pub_date
          activity.first_published_at = DateTime.now
          activity.save!
          Rails.logger.info  "Published /activities/#{activity.slug}"

          # If there a bunch to publish, spread them out in time so they
          # don't clog the gallery.
          pub_date = pub_date - 3.days
        else
          Rails.logger.info  "Updated /activities/#{activity.slug}"
        end

      else
        Rails.logger.info "No output guide"
      end

    end
    Rails.cache.clear
  end
end