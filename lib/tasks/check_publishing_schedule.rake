task :check_publishing_schedule => :environment do

  activities = Activity.where(published: false).joins(:publishing_schedule).where("publish_at < ?", DateTime.now).readonly(false)
  if activities.count == 0
    Rails.logger.info("check_publishing_schedule: Nothing to do")
  else
    activities.each do |activity|
      begin
        activity.published = true
        activity.save!
        Rails.logger.info("check_publishing_schedule: published #{activity.slug}")
      rescue Exception => e
        Rails.logger.error("check_publishing_schedule: failed publishing #{activity.slug} - #{e.message}")
        SlackInProdOnly::send "#just-published", "ERROR!!! Failed in scheduled publish of #{activity.title}"
      end
    end
  end
end