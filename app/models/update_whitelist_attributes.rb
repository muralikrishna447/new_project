module UpdateWhitelistAttributes
  extend ActiveSupport::Concern

  def update_whitelist_attributes(attributes)
    filtered = {}
    return unless attributes.present?
    attributes.each do |key, value|
      filtered[key.to_sym] = value if self.class::WHITELIST_ATTRIBUTES.include?(key.to_sym)
    end
    update_attributes(filtered)
  end
end
