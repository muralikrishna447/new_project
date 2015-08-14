require 'spec_helper'

describe "Forum subdomain" do
  before(:each) do
    @setting = Fabricate :setting, forum_maintenance: true
  end

  # it "redirects to forum with no path" do
  #   get "http://forum.example.com/"
  #   expect(response).to redirect_to("http://www.example.com/forum")
  # end
  #
  # it "redirects to forum with a path" do
  #   get "http://forum.example.com/discussion"
  #   expect(response).to redirect_to("http://www.example.com/forum")
  # end
end
