require 'spec_helper'

describe AggressiveCaching do
  include CacheTesting

  controller do
    include AggressiveCaching
    exclude_from_caching :show

    def index
      head :ok
    end

    def show
      head :ok
    end
  end

  before do
    Version.create()
  end

  it "should cache index page" do
    with_caching do
      get :index
      response['Cache-Control'].should be
    end
  end

  it "should not cache show page" do
    with_caching do
      get :show, id: 123
      response['Cache-Control'].should_not be
    end
  end
end

