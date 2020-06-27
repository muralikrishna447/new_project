require 'optparse'
require 'contentful/management'
require 'pry'

options = {}
option_parser = OptionParser.new do |option|
  option.on('-s', '--space SPACE_ID', 'Contentful space ID') do |space_id|
    options[:space_id] = space_id
  end
  option.on('-a', '--token ACCESS_TOKEN', 'Contentful access token') do |token|
    options[:token] = token
  end
  option.on('-r', '--root ROOT_ENTRY_ID', 'Root Contentful entry ID to initiate deep copy from') do |root_id|
    options[:root_id] = root_id
  end
  option.on('-x', '--slug-suffix SLUG_SUFFIX', 'Suffix to append to slug on deep copied entries') do |slug_suffix|
    options[:slug_suffix] = slug_suffix
  end
  option.on('-d', '--dry-run', 'Dry run, no real copying happens') do
    options[:dry_run] = true
  end
end
option_parser.parse!
raise '--space is required' unless options[:space_id]
raise '--token is required' unless options[:token]
raise '--root is required' unless options[:root_id]
raise '--slug-suffix is required' unless options[:slug_suffix]

client = Contentful::Management::Client.new(options[:token])
space = client.spaces.find(options[:space_id])

ENVIRONMENT = client.environments(options[:space_id]).find('master')
SLUG_SUFFIX = options[:slug_suffix]
IS_DRY_RUN = options[:dry_run]

# Used to maintain a list of common entries that are linked to by multiple
# guides, keyed by slug. We want to link the steak guides to the same programs,
# for example, instead of creating copies of all the links.
COMMON_ENTRIES = {}


def transform_slug(slug)
  return slug if IS_DRY_RUN
  "#{slug}-#{SLUG_SUFFIX}"
end

# Creates a shallow copy of an entry in Contentful with no links.
def shallow_copy_for_entry_id(entry_id)
  entry_clone = ENVIRONMENT.entries.find(entry_id)
  entry_clone.fields[:slug] = transform_slug(entry_clone.fields[:slug])
  content_type = ENVIRONMENT.content_types.find(entry_clone.sys[:contentType].id)

  # Clear out existing links, we'll insert copies of them during the deep copy.
  # Don't set the published fields on collections and guides, let editors do
  # that manually when they're ready.
  case content_type.id
  when 'collection'
    entry_clone.published = false
    entry_clone.items = []
  when 'guide'
    entry_clone.published = false
    entry_clone.default_program = nil
    entry_clone.programs = []
    entry_clone.steps = []
  when 'program'
    entry_clone.fresh_times = []
    entry_clone.frozen_times = []
  when 'step'
    # Steps contain no links, nothing to do
  when 'time'
    # Times contain no links, nothing to do
  else
    raise "Unknown content type #{content_type.id} for entry #{entry_id}"
  end

  return entry_clone if IS_DRY_RUN

  copy = content_type.entries.create(entry_clone.fields)
end

# Expands links by fetching a shallow representation of the linked entry.
def expand_link(link)
  raise "Unknown link: #{link}.to_s" if link.fetch('sys').fetch('type') != 'Link' &&
      link.fetch('sys').fetch('LinkType') != 'Entry'
  ENVIRONMENT.entries.find(link['sys']['id'])
end

# Deep copies a collection from the original to the shallow-copied entry.
def deep_copy_collection!(original, copy)
  items = []
  original.items.each { |item| items << deep_copy(expand_link(item)) }
  copy.items = items
end

# Deep copies a guide from the original to the shallow-copied entry.
def deep_copy_guide!(original, copy)
  copy.default_program = deep_copy(expand_link(original.default_program))

  programs = []
  original.programs.each { |program| programs << deep_copy(expand_link(program)) }
  copy.programs = programs

  steps = []
  original.steps.each { |step| steps << deep_copy(expand_link(step)) }
  copy.steps = steps
end

# Deep copies a program from the original to the shallow-copied entry.
def deep_copy_program!(original, copy)
  fresh_times = []
  original.fresh_times.each { |time| fresh_times << deep_copy(expand_link(time)) }
  copy.fresh_times = fresh_times

  frozen_times = []
  original.frozen_times.each { |time| frozen_times << deep_copy(expand_link(time)) }
  copy.frozen_times = frozen_times
end

# Recusively deep copies a Joule Contentful entry.
def deep_copy(entry)
  content_type_id = entry.sys[:contentType].id

  # If this is an entry we've already copied (as determined by the slug),
  # use the copy we've already made to make sure common links all point to
  # the same place.
  if COMMON_ENTRIES.has_key?(transform_slug(entry.fields[:slug]))
    STDERR.puts "Found #{content_type_id} #{entry.id} with slug #{transform_slug(entry.fields[:slug])} in common entries, using existing copy"
    return COMMON_ENTRIES[transform_slug(entry.fields[:slug])]
  end

  STDERR.puts "Deep copying #{content_type_id} #{entry.id} with slug #{entry.fields[:slug]}"
  copy = shallow_copy_for_entry_id(entry.id)
  case content_type_id
  when 'collection'
    deep_copy_collection!(entry, copy)
  when 'guide'
    deep_copy_guide!(entry, copy)
  when 'program'
    deep_copy_program!(entry, copy)
  when 'step'
    # Steps contain no links, no deep copy required
  when 'time'
    # Times contain no links, no deep copy required
  else
    raise "Unknown content type #{content_type_id} for entry #{entry.id}"
  end

  COMMON_ENTRIES[transform_slug(entry.fields[:slug])] = copy
  return copy if IS_DRY_RUN
  copy.save
  copy.publish
  copy
end


STDERR.puts 'Dry run, not actually copying' if IS_DRY_RUN
root_entry = ENVIRONMENT.entries.find(options[:root_id])
root_copy = deep_copy(root_entry)
STDERR.puts "Created copy of root entry #{root_entry.id} with slug #{root_entry.fields[:slug]}"
STDERR.puts "Copied root has id #{root_copy.id} and slug #{root_copy.fields[:slug]}"
