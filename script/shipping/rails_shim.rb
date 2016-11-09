cs_root = File.expand_path(
  File.join(File.dirname(__FILE__), '..', '..')
)
lib_dir = File.join(cs_root, 'lib')

# require any .rb files from these directories
directories_to_add = [
  File.join(cs_root, 'app', 'workers', 'fulfillment'),
  File.join(lib_dir, 'fulfillment'),
  File.join(lib_dir, 'shopify'),
]

for d in directories_to_add
  Dir[d + '/*.rb'].each {|file|
    require file
  }
end

# Stub out, so Rails.logger works
module Rails
  LOG = Logger.new(STDOUT)
  def self.logger
    LOG
  end
end
