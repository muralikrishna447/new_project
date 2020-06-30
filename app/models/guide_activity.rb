require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class GuideActivity < ApplicationRecord
  validates_uniqueness_of :guide_id
  belongs_to :activity

  def self.create_or_update_from_guide(manifest, guide, force=false)

    ga = GuideActivity.where(guide_id: guide['id'])[0]

    if ! self.should_process(guide, force)
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
      activity.description = guide['description']
      activity.activity_type = ['Recipe']
      activity.difficulty = 'intermediate'
      activity.premium = false
      activity.include_in_gallery = true
      activity.tag_list = self.get_tags(manifest, guide)
      activity.image_id = self.upload_image(self.hero_image(guide))

      self.add_steps(activity, guide)

      activity.save!
      ga.guide_id = guide['id']
      ga.guide_title = guide['title']
      ga.activity_id = activity.id

      ga.guide_digest = self.guide_digest(guide)
      ga.save!

      return ga
    end
  end

  # Typical case looks like "Egg yolks, 6 oz (160 g), about 11"
  # Do our best to parse that but since it is free text, if something doesn't match up, fall back to putting quantity into
  # notes.
  def self.parse_ingredient(line)
    # Skip lines that are like "For sauce:"
    return if /:$/.match(line)

    quantity = nil
    unit = 'a/n'
    extra_note = nil

    # Start by assuming it looks like "Bananas, 500 g, peeled"
    # Then we'll work on the quantity_text to handle other cases.
    title, quantity_text, note = line.split(',', 3).map(&:strip)

    # "6 oz (160 g)"
    matches1 = /.*\((\d+)\s*([^)]*)\)/.match(quantity_text)

    # "1 large"
    matches2 = /^(\d+)\s+([^%]*)$/.match(quantity_text)

    if matches1
      quantity = matches1[1].strip
      if quantity.present?
        unit = matches1[2].strip
        if unit.blank?
          unit = 'ea'
        end
      end

    elsif matches2
      quantity = matches2[1].strip
      unit = 'ea'
      extra_note = matches2[2].strip

    else
      # Can't parse what is in the quantity_text so throw it in the note
      if quantity_text
        quantity_text.gsub!(/\s*a\/n\s*/, '')
        extra_note = quantity_text
      end
    end

    note = [extra_note, note || ''].reject(&:blank?).join(', ')

    return {
      title: title,
      quantity: quantity,
      unit: unit,
      note: note
    }
  end

  private

  def self.image_url(path)
    "http://d92f495ogyf88.cloudfront.net/circulator/" + path
  end

  def self.hero_image(guide)
    # 'image' is portrait and will get cropped aggresively, so it is our last choice
    guide['landscapeImage'] || guide['thumbnail'] || guide['image']
  end

  def self.upload_image(image_path)
    url = "https://www.filestackapi.com/api/store/S3?key=#{Rails.configuration.filepicker_rails.api_key}"
    response = HTTParty.post(url, {body: {url: self.image_url(image_path)}})
    result = JSON.parse(response.body)
    # Put URL back to traditional www.filepicker.io because that is what regexps elsehwere
    # expect to find and turn into CDN url.
    result['url'].gsub! 'cdn.filestackcontent.com', 'www.filepicker.io/api/file'
    result.to_json
  end

  def self.guide_digest(g)
    Digest::MD5.hexdigest(g.to_json)
  end

  def self.should_process(guide, force = false)
    if ! self.hero_image(guide)
      Rails.logger.info "No hero image, ignoring"
      return false
    end

    ga = GuideActivity.where(guide_id: guide['id'])[0]
    if ga
      if ! ga.autoupdate
        Rails.logger.info "Manually edited activity, not overwriting"
        return false
      end

      if ! force && ga.guide_digest == self.guide_digest(guide)
        Rails.logger.info  "Digest hasn't changed, skipping"
        return false
      end
    end

    return true
  end

  def self.get_tags(manifest, g)
    tags = 'sous vide, guide, convertedguide, '
    # Add the names of all collections that contain this guide, those make decent tags
    tags = tags + manifest['collection'].keep_if {|c| c['items'].find {|i| i['id'] == g['id']}}.map { |c| c['title']}.join(', ')
  end

  def self.add_equipment(equipment, line)
    id = Equipment.where(title: line).first_or_create.id
    equipment.push({ equipment: { id: id, title: line }})
  end

  def self.add_ingredient(ingredients, line)
    i = GuideActivity::parse_ingredient(line)
    if i
      ingredients.push({
        ingredient: {
          title: i[:title]
        },
        display_quantity: i[:quantity],
        unit: i[:unit],
        note: i[:note]
      })
    end
  end

  # Guides don't have ingredients and equipment as proper data, they live as plain text
  # in a "helper" field on a step. Nonetheless, they are typically formatted by convention and we
  # can attempt to parse them.

  def self.add_ingredients_and_equipment(a, step)

    lines = step.split(/<.?br>|\n/)

    equipment = []
    ingredients = []
    state = :none

    # Guides obviously need SV but that isn't called out in the guide step, since it is implicit.
    # 'Sous vide setup' is what we've been using on chefsteps.com. It links to /joule.
    self.add_equipment(equipment, 'Sous vide setup')

    lines.each do |line|
      # Ingredient titles don't render correctly even with sanitized &
      line = line.strip.gsub(' & ', ' and ')
      line = CGI.unescapeHTML(line)
      line.gsub!(/<br[^>]*>/, '')

      if line =~ /equipment/i
        state = :equipment
      elsif line =~ /ingredient/i
        state = :ingredients
      elsif line.length >= 4
        case state
        when :equipment
          self.add_equipment(equipment, line)
        when :ingredients
          self.add_ingredient(ingredients, line)
        end
      end
    end

    # Has to be saved first to use update
    a.save!
    a.update_equipment_json(equipment)
    a.update_ingredients_json(ingredients)

    return state != :none
  end

  def self.create_preheat_step(a, g)
    p = g['defaultProgram']
    # If there is no default program, pick a middle temp
    if ! p
      np = g['programs'].length
      p = g['programs'][(np / 2).floor]
    end
    temp = p['cookingTemperature']
    title = "Preheat Joule to [c #{temp}]"

    helper = p['helper']
    helper = helper[0, 1].downcase + helper[1..-1]

    numFreshTimes = p['freshTimes'].length

    t1 = p['freshTimes'][0]['duration'].to_i
    t2 = p['freshTimes'][-1]['duration'].to_i

    t1text = ActionView::Helpers::DateHelper.distance_of_time_in_words(t1.minutes)
    t2text = ActionView::Helpers::DateHelper.distance_of_time_in_words(t2.minutes)

    directions = "For #{helper}, we recommend cooking at [c #{temp}]. Your cooking time will be between #{t1text} and #{t2text} (depending on size)."
    if numFreshTimes == 1
      directions = "For #{helper}, we recommend cooking at [c #{temp}] for #{t1text}."
    end

    directions = directions + "\nTo find your own perfect time and temperature, use the <a href='https://www.chefsteps.com/joule/app'>Joule App</a> or chat with Joule on Facebook Messenger:"
    directions = directions + "\n[sendToMessenger \"Time and temp for #{g['title']}\"]"

    step = Step.create!(
      step_order: 0,
      title: title,
      directions: directions,
    )
    a.steps.push(step)
  end

  def self.add_steps(a, g)
    a.steps.destroy_all

    self.create_preheat_step(a, g)

    idx = 1

    g['steps'].each do |gs|
      handled = false

      title = gs['title'].gsub /\.$/, ''

      image = self.upload_image(gs['noVideoThumbnail'] || gs['image'])

      description = gs['description']

      if gs['helper']
        description += "<p>#{gs['helper']}</p>"

        handled = self.add_ingredients_and_equipment(a, gs['helper'])

        # Steps with helpers often have garbage images for historical reasons
        image = nil
      end

      # Per Rick, skip steps that point them to the google doc feedback form
      if gs['buttonLink'].present? && /2mpaQil/.match(gs['buttonLink'])
        handled = true
      end

      # Per Rick, skip the trivet step
      if title == 'Protect your work surface!'
        handled = true
      end

      if ! handled
        if gs['buttonLink']
          description += "<p class='button-group-inline' style='justify-content: center;'><a class=\"button outline orange\" href=\"#{gs['buttonLink']}\">#{gs['buttonText']}</a>"
        end

        step = Step.create!(
          step_order: idx + 1,
          title: title,
          directions: description,
          image_id: image
        )
        a.steps.push(step)

        idx = idx + 1
      end
    end
  end
end



