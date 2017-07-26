module CsSpree


  module Sync
    def self.ensure_share_joule_code_for_user(user)
      Rails.logger.info "CsSpree::ReferralCodes -> ensure_code_for_user(#{user.id}, #{user.referral_code})"

      if ! user.referral_code
        code = 'sharejoule-' + unique_code { |code| User.unscoped.exists?(referral_code: code) }

        # # For now at least, always doing a fixed $20.00 off Joule only, good for 5 uses
        # ShopifyAPI::Discount.create(
        #     code: code,
        #     discount_type: 'fixed_amount',
        #     value: '20.00',
        #     usage_limit: 5,
        #     applies_to_resource: 'product',
        #     applies_to_id: Rails.configuration.shopify[:joule_product_id]
        # )

        CsSpree::API::Promotions.ensure_share_joule(code)

        # Don't save user until spree succeeds
        user.referral_code = code
        user.save!

        Rails.logger.info "Created unique spree referral discount code #{code} for #{user.id}"
      end

      return user.referral_code
    end

  end

end