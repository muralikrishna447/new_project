require 'spec_helper'

describe Api::V0::MenusController do

  before :all do
    %i[shop_menu recipe_menu studiopass_menu premium_menu not_logged_menu
       free_menu cuts beef_without_bone beef_with_bone dummy_menu].each do |menu|
      Fabricate menu
    end
  end

  context 'should only receive menus marked as not-logged-in for non logged in users' do
    before :all do
      Rails.cache.clear()
    end

    it 'should list of not-logged-in user menus' do
      get :list
      parsed = JSON.parse response.body
      expect(Menu.count).to eq(10)
      # checking not-logged-in parent menu list
      expect(parsed.delete('0').count).to eq(3)
      expect(parsed).to be_empty
    end

    it 'should not-logged-in menu list to be cached' do
      expect(Rails.cache.exist?(Menu::CACHE_KEYS[:not_logged])).to be(true)
    end
  end

  context 'should only receive menus marked as free for non subscribed users' do

    before :all do
      Rails.cache.clear()
    end

    before :each do
      user = Fabricate :user, name: 'Free User', email: 'free@test.com', premium_member: false
      sign_in user
      controller.request.env['HTTP_AUTHORIZATION'] = user.valid_website_auth_token.to_jwt
    end

    it 'should list of free user menus' do
      get :list
      parsed = JSON.parse response.body
      expect(Menu.count).to eq(10)
      # checking free user parent menu list
      expect(parsed.delete('0').count).to eq(2)
      expect(parsed).to be_empty
    end

    it 'should free menu list to be cached' do
      expect(Rails.cache.exist?(Menu::CACHE_KEYS[:free])).to be(true)
    end

  end

  context 'should only receive menus marked as studio for studiopass users' do

    before :all do
      Rails.cache.clear()
    end

    before :each do
      user = Fabricate :user, name: 'StudioPass User', email: 'studio_pass@test.com'
      sign_in user
      controller.request.env['HTTP_AUTHORIZATION'] = user.valid_website_auth_token.to_jwt
      allow_any_instance_of(User).to receive(:studio?).and_return(true)
    end

    it 'should list of studiopass user menus' do
      get :list
      parsed = JSON.parse response.body
      expect(Menu.count).to eq(10)
      # checking studiopass user parent menu list
      expect(parsed.delete('0').count).to eq(4)
      # checking studiopass user sub menu list
      expect(parsed.delete('6').count).to eq(2)
      expect(parsed).to be_empty
    end

    it 'should studio menu list to be cached' do
      expect(Rails.cache.exist?(Menu::CACHE_KEYS[:studio])).to be(true)
    end

  end

  context 'should only receive menus marked as premium for premium users' do

    before :all do
      Rails.cache.clear()
    end

    before :each do
      user = Fabricate :user, name: 'Premium User', email: 'premium@test.com', premium_member: true
      sign_in user
      controller.request.env['HTTP_AUTHORIZATION'] = user.valid_website_auth_token.to_jwt
    end

    it 'should list of premium user menus' do
      get :list
      parsed = JSON.parse response.body
      expect(Menu.count).to eq(10)
      # checking studiopass user parent menu list
      expect(parsed.delete('0').count).to eq(5)
      # checking studiopass user sub menu list
      expect(parsed.delete('6').count).to eq(2)
      expect(parsed).to be_empty
    end

    it 'should premium menu list to be cached' do
      expect(Rails.cache.exist?(Menu::CACHE_KEYS[:premium])).to be(true)
    end

  end

  context 'should only receive the menus which are having at least having one permission' do

    before :all do
      Rails.cache.clear()
    end

    before :each do
      user = Fabricate :user, name: 'Admin User', email: 'admin@test.com'
      user.role = 'admin'
      user.save
      sign_in user
      controller.request.env['HTTP_AUTHORIZATION'] = user.valid_website_auth_token.to_jwt
    end

    it 'should list of all menus for admin menus' do
      get :list
      parsed = JSON.parse response.body
      expect(Menu.count).to eq(10)
      # checking studiopass user parent menu list
      expect(parsed.delete('0').count).to eq(7)
      # checking studiopass user sub menu list
      expect(parsed.delete('6').count).to eq(2)
      expect(parsed).to be_empty
    end

    it 'should admin menu list to be cached' do
      expect(Rails.cache.exist?(Menu::CACHE_KEYS[:admin])).to be(true)
    end
  end

  context 'should purge cache while create/updating any menu' do
    it 'creating new menu for checking cache' do
      get :list
      Menu.create(id: 11, name: 'New menu', url: '/new_menu')
      Menu::CACHE_KEYS.each do |_, cache_key|
        expect(Rails.cache.exist?(cache_key)).to be(false)
      end
    end
  end
end
