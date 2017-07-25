module CsSpree::Api::ShareJoulePromotion
  def self.ensure(code)
    Rails.logger.info "#{self.class.name}.ensure(#{code})"

  end
end