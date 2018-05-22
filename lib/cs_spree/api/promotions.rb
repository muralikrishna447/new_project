module CsSpree::Api::Promotions
  def self.ensure_share_joule(code)
    begin
      CsSpree.post_api('/api/v1/cs_promotions/ensure', {
          :cs_promotion => {
              :type => 'share_joule',
              :code => code
          }
      })
    rescue StandardError => e
      Rails.logger.error "Error in ensure_share_joule(#{code}) #{e}"
      nil
    end
  end
end