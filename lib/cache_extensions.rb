 module CacheExtensions
  class << self
    # This allows caching with an expiration, but if there is an exception thrown from the block that produces
    # the cache value, it uses the old value from the cache, retrying occasionally. The trick is to
    # not put an expiration on the cache value, but on a separate generated key, because Rails.cache.read honors
    # expirations set earlier. I'm surprised Rails.cache.fetch doesn't just handle this.
    #
    # key - the cache key to read and update if needed
    # expiration - how long the key should be good for under normal circumstances
    # retry_expiration - how long between retries if the block raises an exception. if expiration is long, you may want to
    # make this shorter.
    # block - should return the updated value, or raise an exception if it can't be retrieved
    #
    # Inspired by https://github.com/ReliveRadio/reliveradio-website/blob/4874cf4158361c73a693e65643d9e7f11333d9d6/app/helpers/external_api_helper.rb
    def fetch_with_rescue(key, expiration, retry_expiration)
      freshness_key = 'ExpirationFor_' + key
      result = Rails.cache.read(key)
      freshness_result = Rails.cache.read(freshness_key)

      if freshness_result.blank? || result.blank?
        begin
          result = yield
          Rails.cache.write(key, result)
          Rails.cache.write(freshness_key, 'fresh', expires_in: expiration)
        rescue StandardError => error
          Rails.cache.write(freshness_key, 'retrying', expires_in: retry_expiration)
          Rails.logger.error("Got error #{error} attempting to update cache #{key}. Using saved value for #{retry_expiration} additional time.")
          Librato.increment 'fetch_with_rescue.block_raised.#{key}', sporadic: true
        end
      end

      return result
    end
  end
end
