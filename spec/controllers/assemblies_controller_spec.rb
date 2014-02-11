require 'spec_helper'

describe AssembliesController do
  context "#get" do
    context 'user is not logged in' do
      let!(:user) { Fabricate(:user, id: 29) }
      let!(:assembly) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 39.00, published: true ) }
      let!(:landing_page) { Fabricate(:page, title: "Clummy LP", content: "You so clummy", primary_path: "/classes/clummy") }

      # before do
      #   sign_in user
      # end

      it 'redirects to landing page' do
        get :show, id: 'clummy'
        expect(response.status).to eq(302)
      end

      it 'computes discounted price' do
        get :landing, id: 'clummy', coupon: 'a1b71d389a50'
        expect(assigns(:discounted_price)).to eq(29)
        expect(session[:coupon]).to eq('a1b71d389a50')
      end
    end
  end

  context "#trial" do
    let!(:assembly){ Fabricate(:assembly, title: "Free Trial", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:trial_code) { Base64.encode64("#{assembly.id}-1") }

    subject { get :trial, trial_token: trial_code }

    it 'it should set the trial code into the session' do
      subject
      expect(session[:free_trial]).to eq trial_code
    end

    it 'it should redirect to the landing page' do
      expect(subject).to redirect_to(landing_class_url(assembly))
    end
  end

  context "#trial duration split" do
    let!(:assembly){ Fabricate(:assembly, title: "Free Trial", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:trial_code) { Base64.encode64("#{assembly.id}-0") }

    subject { get :trial, trial_token: trial_code }

    it 'it should pick a non-zero trial duration and store in session' do
      subject
      expect(Assembly.free_trial_hours(session[:free_trial])).not_to eq 0
    end
  end
end
