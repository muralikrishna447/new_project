class AlgoliaSync
  @queue = :algolia_sync
  def self.perform(activity_id)
    Rails.logger.info "Syncing activity [#{activity_id}] to Algolia"
    begin
      activity = Activity.find_by_id(activity_id)
      if activity
        activity.title = CGI.unescapeHTML(activity.title.to_s)
        activity.description = CGI.unescapeHTML(activity.description.to_s)
        activity.short_description = CGI.unescapeHTML(activity.short_description.to_s)
        activity.byline = CGI.unescapeHTML(activity.byline.to_s)
        activity.index!
      else
        index = Algolia::Index.new(Activity.index_name)
        index.delete_object(activity_id)
      end
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
