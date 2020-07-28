require 'rubygems/package'

namespace :update_rethinkdb do
  desc 'Update existing user has studiopass or not in cs-bloom-api rethinkdb'
  task studiopass_user: :environment do
    end_point = Rails.application.config.shared_config[:bloom][:api_endpoint]
    Subscription.active.find_in_batches(batch_size: 500).each do |subscriptions|
      subscriptions.each do |subscription|
        Rails.logger.info("Subscription Id -- #{subscription.id} ")
        begin
          Retriable.retriable tries: 3 do
            Faraday.get do |req|
              req.url "#{end_point}/users/#{subscription.user_id}/update?apiKey=xchefsteps&ssoId=#{subscription.user_id}"
              req.options[:timeout] = 30
            end
          end
          Librato.increment "studiopass.user.update.rethinkdb.suceess"
          Rails.logger.info("Studiopass user updated successfully -- #{subscription.id}")
        rescue Exception => e
          Librato.increment "studiopass.user.update.rethinkdb.failed"
          Rails.logger.error "Error update studiopass user in rethinkdb guide #{subscription.id}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end
    Librato.tracker.flush
  end
end
