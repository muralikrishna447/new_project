require 'spec_helper'

describe "_global_navigation" do
  it "excludes authentication links if show_auth is false" do
    render "layouts/global_navigation", show_auth: false
    rendered.should_not have_selector(".authentication")
  end
end
