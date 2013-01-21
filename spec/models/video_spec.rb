require 'spec_helper'

describe Video do
  let(:video) { Fabricate(:video, title: 'foo', youtube_id: 'bar') }
end
