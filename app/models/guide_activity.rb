class GuideActivity < ActiveRecord::Base
  validates_uniqueness_of :guide_id
  belongs_to :activity
  attr_accessible :activity_id, :guide_id, :guide_title, :autoupdate, :guide_digest

  def self.create_or_update_from_guide(manifest, guide, force=false)

    ga = GuideActivity.where(guide_id: guide['id'])[0]

    if ! should_process(guide, force)
      return nil
    end

    activity = nil

    Activity.transaction do

      if ga
        # Already exists and allowed to update
        activity = Activity.find(ga.activity_id)
      else
        # First-timer
        activity = Activity.new
        ga = GuideActivity.new
      end

      activity.title = guide['title']
      activity.description = description(guide)
      activity.activity_type = ['Recipe']
      activity.difficulty = 'intermediate'
      activity.premium = false
      activity.include_in_gallery = true
      activity.tag_list = get_tags(manifest, guide)
      activity.image_id = upload_image(hero_image(guide))

      add_steps(activity, guide)

      activity.save!
      ga.guide_id = guide['id']
      ga.guide_title = guide['title']
      ga.activity_id = activity.id

      ga.guide_digest = guide_digest(guide)
      ga.save!

      return ga
    end
  end
end

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
    Rails.logger.info "No hero image, ignoring"
    return false
  end

  ga = GuideActivity.where(guide_id: guide['id'])[0]
  if ga
    if ! ga.autoupdate
      Rails.logger.info "Manually edited activity, not overwriting"
      return false
    end

    if ! force && ga.guide_digest == guide_digest(guide)
      Rails.logger.info  "Digest hasn't changed, skipping"
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
  # Skip lines that are like "For sauce:"
  return if /:$/.match(line)

  quantity = nil
  unit = 'a/n'

  title, quantityText, note = line.split(',').map(&:strip)
  matches = /.*\(([\S]*)\S*([^)]*)\)/.match(quantityText)

  if matches
    quantity = matches[1].strip
    if quantity.present?
      unit = matches[2].strip
      if unit.blank?
        unit = 'ea'
      end
    end
  else
    # Can't parse what is in the quantityText so throw it in the note
    note = [quantityText, note || ''].reject(&:blank?).join(', ')
  end

  i = {
    ingredient: {
      title: title
    },
    display_quantity: quantity,
    unit: unit,
    note: note
  }

  ingredients.push(i)
end

# Guides don't have ingredients and equipment as proper data, they live as plain text
# in a "helper" field on a step. Nonetheless, they are typically formatted by convention and we
# can attempt to parse them.

def add_ingredients_and_equipment(a, step)

  lines = step.split(/<.?br>|\n/)

  equipment = []
  ingredients = []
  state = :none

  # Guides obviously need SV but that isn't called out in the guide step, since it is implicit.
  # 'Sous vide setup' is what we've been using on chefsteps.com. It links to /joule.
  add_equipment(equipment, 'Sous vide setup')

  lines.each do |line|
    # Ingredient titles don't render correctly even with sanitized &
    line = line.strip.gsub(' & ', ' and ')
    line = CGI.unescapeHTML(line)

    if line =~ /equipment/i
      state = :equipment
    elsif line =~ /ingredient/i
      state = :ingredients
    elsif line.length >= 4
      case state
      when :equipment
        add_equipment(equipment, line)
      when :ingredients
        add_ingredient(ingredients, line)
      end
    end
  end

  # Has to be saved first to use update
  a.save!
  a.update_equipment_json(equipment)
  a.update_ingredients_json(ingredients)

  return state != :none
end

def add_steps(a, g)
  a.steps.destroy_all

  g['steps'].each_with_index do |gs, idx|


    title = gs['title'].gsub /\.$/, ''

    image = upload_image(gs['noVideoThumbnail'] || gs['image'])

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
  [sendToMessenger \"Time and temp for #{guide['title']}\"]
  EOT
end

