require 'spec_helper'

describe AggressiveCaching do
  include CacheTesting

  with_caching do
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
  end

  before do
    Version.create()
  end

  it "should cache index page" do
    get :index
    response['Cache-Control'].should be
  end

  it "should not cache show page" do
    get :show, id: 123
    response['Cache-Control'].should_not be
  end
end

