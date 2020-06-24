require 'spec_helper'

describe EquipmentController do
  describe "#index" do
    it "should cause a not authorized error when no user is logged in" do
      expect { get :index, format: :html }.to raise_error(CanCan::AccessDenied)
    end
  end

  describe "#destroy" do
    it "should cause a not authorized error when no user is logged in" do
      expect { delete :destroy, params: {id: '122'} }.to raise_error(CanCan::AccessDenied)
    end
  end
end
