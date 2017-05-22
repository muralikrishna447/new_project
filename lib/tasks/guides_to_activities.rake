require 'httparty'

manifest_url = 'https://www.chefsteps.com/api/v0/content_config/manifest?content_env=production'

def hero_image(guide)
  # 'image' is portrait and will get cropped aggresively, so it is our last choice
  guide['landscapeImage'] || guide['thumbnail'] || guide['image']
end

def should_process(guide)
  # No slimmies, activities without images are :( looking
  return false if ! hero_image(guide)
  ga = GuideActivity.where(guide_id: guide['id'])[0]
  return false if ga && ! ga.autoupdate
  return true
end

def get_tags(manifest, g)
  tags = 'sous vide, '
  # Add the names of all collections that contain this guide, those make decent tags
  tags = tags + manifest['collection'].keep_if {|c| c['items'].find {|i| i['id'] == g['id']}}.map { |c| c['title']}.join(', ')
end

def upload_image(image_path)
  url = "https://www.filestackapi.com/api/store/S3?key=#{Rails.configuration.filepicker_rails.api_key}&path='"
  image_base = "http://d92f495ogyf88.cloudfront.net/circulator/"
  response = HTTParty.post(url, {body: {url: image_base + image_path}})
  puts response.body
  response.body
end

def guide_to_activity(manifest, g)
  ga = GuideActivity.where(guide_id: g['id'])[0]
  a = nil

  if ga
    # Already exists and allowed to update
    a = Activity.find(ga.activity_id)
  else
    # First-timer
    a = Activity.new
    ga = GuideActivity.new
  end

  a.title = g['title']
  a.description = g['description']
  a.activity_type << 'Recipe'
  a.difficulty = 'intermediate'
  a.premium = false
  a.include_in_gallery = true
  a.tag_list = get_tags(manifest, g)

  # Even though we might be updating an activity, don't update image every time b/c filepicker has no idempotent
  # way to do this, and it seems crazy to create a million duplicates.
  if ! a.image_id
    a.image_id = upload_image(hero_image(g))
  end

  # time/temp messenger/app thing
  # steps

  a.save!
  ga.guide_id = g['id']
  ga.activity_id = a.id
  ga.save!

  puts "Processed http://localhost:3000/activities/#{a.slug}"
end

namespace :activities do
  task :guides_to_activities => :environment do
    response = HTTParty.get(manifest_url)
    manifest = JSON.parse(response.body)
    manifest['guide'].each do |guide|
      if should_process(guide)
        guide_to_activity(manifest, guide)
        break
      end
    end
  end
end