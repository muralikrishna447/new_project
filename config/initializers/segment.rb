require 'segment'
if Rails.env.development? || Rails.env.test?
  Analytics = Segment::Analytics.new({
    write_key: 'd1iKTmkGittQwXQbBSY7egXumHgmTai4'
  })
else
  Analytics = Segment::Analytics.new({
    write_key: ENV['SEGMENT_WRITE_KEY']
  })
end
