require 'retriable'
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

  def self.basic_auth
    CONFIG['basic_auth']
  end

  def self.merge_api_headers(headers = {})
    headers['X-Spree-Token'] = api_key if api_key.present?
    headers['Authorization'] = basic_auth if basic_auth.present?
    headers
  end

  RETRY_PROC = Proc.new do |exception, try, elapsed_time, next_interval|
    Rails.logger.error "CsSpree::API #{exception.class}: '#{exception.message}' - #{try} tries in #{elapsed_time} seconds and #{next_interval} seconds until the next try."
  end

  def self.get_api(path, params = {})
    Retriable.retriable(:tries => 2, on_retry: RETRY_PROC) do |attempt|
      url = "#{hostname}#{path}"
      Rails.logger.info "CsSpree::API GET #{url} with (#{params}) Attempt(#{attempt}) "
      headers = merge_api_headers 'Content-Type' => 'application/json'
      result = HTTParty.get(url,
                             :body => params.to_json,
                             :headers => headers)
      Rails.logger.info "CsSpree::API #{url} with (#{params}) Attempt(#{attempt}) -> (#{result.to_json})"

      unless result.success?
        raise StandardError.new "#{result.message}:#{result.code}"
      end

      result
    end
  end


  def self.post_api(path, params = {})
    Retriable.retriable(:tries => 2, on_retry: RETRY_PROC) do |attempt|
      url = "#{hostname}#{path}"
      Rails.logger.info "CsSpree::API POST #{url} with (#{params}) Attempt(#{attempt}) "
      headers = merge_api_headers 'Content-Type' => 'application/json'
      result = HTTParty.post(url,
                             :body => params.to_json,
                             :headers => headers)
      Rails.logger.info "CsSpree::API #{url} with (#{params}) Attempt(#{attempt}) -> (#{result.to_json})"

      unless result.success?
        raise StandardError.new "#{result.message}:#{result.code}"
      end

      result
    end
  end

end
