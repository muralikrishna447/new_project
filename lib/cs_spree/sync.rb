module CsSpree


  module Sync
    def self.ensure_share_joule_code_for_user(user)
      Rails.logger.info "CsSpree::ReferralCodes -> ensure_code_for_user(#{user.id}, #{user.referral_code})"

      if ! user.referral_code
        code = 'sharejoule-' + unique_code { |code| User.unscoped.exists?(referral_code: code) }

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