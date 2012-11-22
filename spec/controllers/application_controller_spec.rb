require 'spec_helper'

describe ApplicationController, type: :controller do
  describe "API serves global navigation header" do
    before do
      get "global_navigation"
    end

    it "returns the header html" do
      response.should render_template(partial: 'layouts/_header')
    end
  end
end

describe ApplicationController, 'version expose' do
  before do
    Version.stub(:current) { 'current version' }
  end

  it 'exposes current version' do
    controller.version.should == 'current version'
  end
end
