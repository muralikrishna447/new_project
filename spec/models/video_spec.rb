require 'spec_helper'

describe Video do

  describe 'filmstrip' do
    it 'has content to display' do
      new_content = Activity.create! title: 'foo', youtube_id: 'bar', published: true
      filmstrip = Video.filmstrip_videos
      filmstrip.count.should > 0
    end
  end

end
