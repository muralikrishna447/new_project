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

describe ApplicationController, '#last_stored_location_for', type: :controller do
  controller do
    before_filter :authenticate_user!

    def show
      head :ok
    end
  end
  let(:session) { {'user_return_to' => '/return-path'} }

  before do
    controller.stub(:session) { session }
    get :show, id: 1
  end

  it 'return nil if location has not been stored' do
    controller.last_stored_location_for(:user).should_not be
  end

  context 'location has been stored' do
    before { controller.stored_location_for(:user) }

    it 'returns the last stored location' do
      controller.last_stored_location_for(:user).should == '/return-path'
    end

    it 'clears last stored location on access' do
      controller.last_stored_location_for(:user)
      controller.last_stored_location_for(:user).should_not be
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
