require 'spec_helper'

feature 'charge for courses', :js => true do

=begin
  describe 'charge form' do
    assembly = Fabricate(:assembly, title: "Clummmy", assembly_type: :project, price: 147.47 )
    let!(:rendered) { render_to_string :partial => "assemblies/assemby_buy_button", assembly: assembly, enrolled: false }
    let(:page) { Capybara::Node::Simple.new(rendered) }
    it { page.should have_selector('form') }
  end
=end


  
end