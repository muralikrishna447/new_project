require 'spec_helper'

describe 'devise/registrations/complete_registration.html.haml' do
  before do
    view.stub(:session) { { 'devise.facebook_data' => create_auth } }
    render
    @page = Capybara::Node::Simple.new(rendered)
  end

  # it 'renders facebook img src from uid in session' do
  #   rendered.should include 'graph.facebook.com/ABC/picture'
  # end

  # it 'renders name input from session' do
  #   @page.find('[name="user[name]"]').value.should == 'Bob User'
  # end

  # it 'renders email input from session' do
  #   @page.find('[name="user[email]"]').value.should == 'test-user@test.com'
  # end

  def create_auth
    Hashie::Mash.new(
      provider: :facebook,
      uid: 'ABC',
      info: { email: 'test-user@test.com' },
      extra: {
        raw_info: { name: 'Bob User' }
      }
    )
  end
end
