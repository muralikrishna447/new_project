require 'spec_helper'

describe ApplicationController, type: :controller do
  describe "API serves global navigation header" do
    before do
      get "global_navigation"
    end

    it "returns the header html" do
      response.should render_template(partial: 'layouts/_header')
    end

    it "sets Access-Control-Allow-Origin to include chefstepsblog.com" do
      response.header['Access-Control-Allow-Origin'].should include('chefstepsblog.com')
    end

    it "sets Access-Control-Request-Method only for GET" do
      response.header['Access-Control-Request-Method'].should include('GET')
    end
  end
end

