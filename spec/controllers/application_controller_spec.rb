require 'spec_helper'

describe ApplicationController do
  describe "API serves global navigation header" do
    before do
      get "global_navigation"
    end

    it "returns the header html" do
      response.should render_template(partial: 'layouts/_header')
    end
  end
end

