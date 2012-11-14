require 'spec_helper'

describe HomeController do
  it "caches controller action" do
    CacheTesting.with_caching do
      controller.class.should_receive(:caches_action).with('index', {layout: false})
      controller.class.caches_actions
    end
  end

  it "does not cache index action if excluded" do
    CacheTesting.with_caching do
      controller.class.caches_actions exclude: :index
      controller.class.should_not_receive(:caches_action)
    end
  end
end

