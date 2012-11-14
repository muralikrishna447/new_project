require 'spec_helper'

describe ActionCaching do
  include CacheTesting

  with_caching do
    controller(HomeController) do
    end
  end

  it "caches controller action" do
    controller.class.should_receive(:caches_action).with(:index, {layout: false})
    get :index
  end

  context 'with action exclude' do
    before do
      controller.class.exclude_from_action_caching :index
    end

    it "does not cache index action" do
      controller.class.should_not_receive(:caches_action)
      get :index
    end
  end
end

