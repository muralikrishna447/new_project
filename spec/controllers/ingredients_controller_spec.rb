require 'spec_helper'

describe IngredientsController do
  describe "#index" do
    it "should cause a not authorized error when no user is logged in" do
      expect { get :index }.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "#destroy" do
    it "should cause a not authorized error when no user is logged in" do
      expect { delete :destroy }.to raise_error(CanCan::AccessDenied)
    end
  end
end
