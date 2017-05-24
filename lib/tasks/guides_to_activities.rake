require 'httparty'

manifest_url = 'https://www.chefsteps.com/api/v0/content_config/manifest?content_env=production'

def image_url(path)
  "http://d92f495ogyf88.cloudfront.net/circulator/" + path
end

def hero_image(guide)
  # 'image' is portrait and will get cropped aggresively, so it is our last choice
  guide['landscapeImage'] || guide['thumbnail'] || guide['image']
end

def upload_image(image_path)
  url = "https://www.filestackapi.com/api/store/S3?key=#{Rails.configuration.filepicker_rails.api_key}"
  response = HTTParty.post(url, {body: {url: image_url(image_path)}})
  result = JSON.parse(response.body)
  # Put URL back to traditional www.filepicker.io because that is what regexps elsehwere
  # expect to find and turn into CDN url.
  result['url'].gsub! 'cdn.filestackcontent.com', 'www.filepicker.io/api/file'
  result.to_json
end

def should_process(guide)
  # No slimmies, activities without images are :( looking
  return false if ! hero_image(guide)
  ga = GuideActivity.where(guide_id: guide['id'])[0]
  return false if ga && ! ga.autoupdate
  return true
end

def get_tags(manifest, g)
  tags = 'sous vide, guide, convertedguide, '
  # Add the names of all collections that contain this guide, those make decent tags
  tags = tags + manifest['collection'].keep_if {|c| c['items'].find {|i| i['id'] == g['id']}}.map { |c| c['title']}.join(', ')
end

def add_steps(a, g)
  a.steps.destroy_all

  g['steps'].each_with_index do |gs, idx|

    title = gs['title']
    title.gsub! /\.$/, ''

    image = upload_image(gs['noVideoThumbnail'] || gs['image'])

    description = gs['description']

    if gs['helper']
      description += "<p>#{gs['helper']}</p>"

      # Steps with helpers often have garbage images for historical reasons
      image = nil
    end

    if gs['buttonLink']
      description += "<p class='button-group-inline' style='justify-content: center;'><a class=\"button outline orange\" href=\"#{gs['buttonLink']}\">#{gs['buttonText']}</a>"
    end

    step = Step.create!(
      step_order: idx,
      title: gs['title'],
      directions: description,
      image_id: image
    )
    a.steps.push(step)
  end
end

def guide_to_activity(manifest, g)
  puts "------ Processing #{g['title']}"
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
  a.description = "#{g['description']}<p>Pick your doneness using Joule on Facebook Messenger.
[sendToMessenger \"Cook #{g['title']}\"]</p>"
  a.activity_type = ['Recipe']
  a.difficulty = 'intermediate'
  a.premium = false
  a.include_in_gallery = true
  a.tag_list = get_tags(manifest, g)

  # Even though we might be updating an activity, don't update image every time b/c filepicker has no idempotent
  # way to do this, and it seems crazy to create a million duplicates.
  # TODO put this back
  if ! a.image_id
    a.image_id = upload_image(hero_image(g))
  end

  add_steps(a, g)

  a.save!
  ga.guide_id = g['id']
  ga.activity_id = a.id
  ga.save!

  puts "------ Output http://localhost:3000/activities/#{a.slug}"
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
    Rails.cache.clear
  end
end