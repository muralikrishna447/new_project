require 'cs_spree/sync'

module CsSpree

  CONFIG = YAML.load(ERB.new(File.read(Rails.root.join('config/cs_spree.yml'))).result)[Rails.env]

  def self.front_end_live?
    CONFIG['front_end_live']
  end

  def self.back_end_live?
    CONFIG['back_end_live']
  end

  def self.hostname
    CONFIG['hostname']
  end

  def self.api_key
    CONFIG['api_key']
  end
end
