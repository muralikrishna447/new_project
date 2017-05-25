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

def guide_digest(g)
  Digest::MD5.hexdigest(g.to_json)
end

def should_process(guide, force = false)
  if ! hero_image(guide)
    puts "No hero image, ignoring"
    return false
  end

  ga = GuideActivity.where(guide_id: guide['id'])[0]
  if ga
    if ! ga.autoupdate
      puts "Manually edited activity, not overwriting"
      return false
    end

    if ! force && ga.guide_digest == guide_digest(guide)
      puts "Digest hasn't changed, skipping"
      return false
    end
  end

  return true
end

def get_tags(manifest, g)
  tags = 'sous vide, guide, convertedguide, '
  # Add the names of all collections that contain this guide, those make decent tags
  tags = tags + manifest['collection'].keep_if {|c| c['items'].find {|i| i['id'] == g['id']}}.map { |c| c['title']}.join(', ')
end

def add_equipment(equipment, line)
  id = Equipment.where(title: line).first_or_create.id
  equipment.push({ equipment: { id: id, title: line }})
end

# Typical case looks like "Egg yolks, 6 oz (160 g), about 11"
# Do our best to parse that but since it is free text, if something doesn't match up, fall back to putting quantity into
# notes.
def add_ingredient(ingredients, line)
  title, quantityText, note = line.split(',').map(&:strip)
  quantity, unit = /.*\(([\S]*)\S*([^)]*)\)/.match(quantityText).captures.map(&:strip)
  if quantity
    if ! unit
      unit = 'ea'
    end
  else
    note = [quantityText, note].join(', ')
  end

  ingredients.push(
    ingredient: {
      title: title
    },
    display_quantity: quantity,
    unit: unit,
    note: note
  )

  puts 'HELLO'
  puts line
  puts ingredients.last
end

# Guides don't have ingredients and equipment as proper data, they live as plain text
# in a "helper" field on a step. Nonetheless, they are typically formatted by convention and we
# can attempt to parse them.

def add_ingredients_and_equipment(a, step)
  lines = step.split('<br>')
  equipment = []
  ingredients = []
  state = :none

  lines.each do |line|
    line.strip!
    if line =~ /equipment/i
      state = :equipment
    elsif line =~ /ingredient/i
      state = :ingredients
    elsif line.length >= 5
      case state
      when :equipment
        add_equipment(equipment, line)
      when :ingredients
        add_ingredient(ingredients, line)
      end
    end
  end

  a.update_equipment_json(equipment)
  a.update_ingredients_json(ingredients)

  return state != :none
end

def add_steps(a, g)
  a.steps.destroy_all

  g['steps'].each_with_index do |gs, idx|

    title = gs['title'].gsub /\.$/, ''

    #image = upload_image(gs['noVideoThumbnail'] || gs['image'])

    description = gs['description']

    handled = false
    if gs['helper']
      description += "<p>#{gs['helper']}</p>"

      handled = add_ingredients_and_equipment(a, gs['helper'])

      # Steps with helpers often have garbage images for historical reasons
      image = nil
    end

    if ! handled

      if gs['buttonLink']
        description += "<p class='button-group-inline' style='justify-content: center;'><a class=\"button outline orange\" href=\"#{gs['buttonLink']}\">#{gs['buttonText']}</a>"
      end

      step = Step.create!(
        step_order: idx,
        title: title,
        directions: description,
        image_id: image
      )
      a.steps.push(step)
    end
  end
end

def description(guide)
  <<-EOT
  #{guide['description']}
  <div class="flex-center text-center" style="flex-direction: column;">
    <div class="text-center" style="max-width: 400px; margin-bottom: 11px;">
      <i>Pick your perfect time and temperature using Joule on Facebook Messenger</i>
    </div>
    <div>
      [sendToMessenger \"Time and temp for #{guide['title']}\"]
    </div>
  </div>
  EOT
end

def guide_to_activity(manifest, g, force=false)

  digest = guide_digest(g)

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
  a.description = description(g)
  a.activity_type = ['Recipe']
  a.difficulty = 'intermediate'
  a.premium = false
  a.include_in_gallery = true
  a.tag_list = get_tags(manifest, g)
  a.image_id = upload_image(hero_image(g))

  add_steps(a, g)

  a.save!
  ga.guide_id = g['id']
  ga.activity_id = a.id

  ga.guide_digest = digest
  ga.save!

  puts "------ Output http://localhost:3000/activities/#{a.slug}"
end

namespace :activities do
  task :guides_to_activities, [:force] => :environment do |t, args|
    args.with_defaults(force: false)
    response = HTTParty.get(manifest_url)
    manifest = JSON.parse(response.body)

    manifest['guide'].each do |guide|
      puts "------ Considering #{guide['title']}"

      if should_process(guide, args[:force])
        guide_to_activity(manifest, guide)
      end
      break
    end
    Rails.cache.clear
  end
end