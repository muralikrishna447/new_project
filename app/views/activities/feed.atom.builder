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
          entry.div style: "position: relative; padding-bottom: 56.25%; padding-top: 25px; height: 0px" do |video|
            video.iframe style: "position: absolute; top: 0; bottom: 0; width: 100%; height: 100%;", src: youtube_url(activity.youtube_id)
          end
        end
        if activity.transcript?
          xhtml.h3 'Transcript'
          xhtml.div activity.transcript
        end
      end

    end
  end
end