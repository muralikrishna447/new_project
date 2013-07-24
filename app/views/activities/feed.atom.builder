atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated @updated

  @activities.each do |activity|

    feed.entry( activity ) do |entry|
      entry.url activity_path(activity)
      entry.title activity.title
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