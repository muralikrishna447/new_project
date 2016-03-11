class AlgoliaSync
  @queue = :algolia_sync
  def self.perform(activity_id)
    Rails.logger.info "Syncing activity [#{activity_id}] to Algolia"
    begin
      Activity.find(activity_id).index!
    rescue Exception => e
      Librato.increment("algolia.sync_failed.activity")
      msg = "Exception #{e.message} while syncing activity [#{activity_id}] to Algolia"
      Rails.logger.error msg
      raise msg
    end
    Librato.increment("algolia.synced.activity")
    Rails.logger.info "Finished syncing activity [#{activity_id}] to Algolia"  
  end
end
