require 'spec_helper'

describe "_global_navigation" do
  it "excludes authentication links if show_auth is false" do
    render "layouts/global_navigation", show_auth: false, show_forum: true
    rendered.should_not have_selector(".authentication")
  end

  it "excludes forum link if show_forum is false" do
    render "layouts/global_navigation", show_auth: false, show_forum: false
    rendered.should_not include("Forums")
  end
end
