atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated @updated

  @activities.by_published_at('desc').chefsteps_generated.each do |activity|
    next if activity.updated_at.blank?
    next if ! activity.published?

    feed.entry( activity ) do |entry|
      entry.url activity_path(activity)
      entry.title activity.title
      # the strftime is needed to work with Google Reader.
      entry.updated(activity.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

      entry.content :type => 'xhtml' do |xhtml|
        if activity.has_description?
          xhtml.p activity.description
        end
        if activity.youtube_id?
          xhtml.iframe src: youtube_url(activity.youtube_id)
        end
        if activity.transcript?
          xhtml.h3 'Transcript'
          xhtml.div activity.transcript
        end
      end

    end
  end
end