describe Api::V0::PremiumGiftCertificateController do
  before :each do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', premium_member: false, name: 'John Doe', role: 'user'
    issued_at = (Time.now.to_f * 1000).to_i
    service_claim = {
        iat: issued_at,
        service: 'CSSpree'
    }
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s
    request.env['HTTP_AUTHORIZATION'] = @service_token
    Rails.cache.clear
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'POST /generate_cert_and_send_email' do
    it 'should not succeed with no parameters' do
      post :generate_cert_and_send_email
      response.should_not be_success
    end

    it 'should create a certificate' do
      post :generate_cert_and_send_email, { premium_identifier: Time.now.to_i, user_id: @user.id, price: 29, email: 'johndoe@chefsteps.com'}
      response.should be_success

      cert = PremiumGiftCertificate.find_by_purchaser_id(@user.id)
      expect(cert).not_to be_nil
    end

    it 'should be idempotent' do
      premium_id = Time.now.to_i
      post :generate_cert_and_send_email, { premium_identifier: premium_id, user_id: @user.id, price: 29, email: 'johndoe@chefsteps.com'}
      response.should be_success

      cert = PremiumGiftCertificate.find_by_purchaser_id(@user.id)
      expect(cert).not_to be_nil

      #a second call should return 201
      post :generate_cert_and_send_email, { premium_identifier: premium_id, user_id: @user.id, price: 29, email: 'johndoe@chefsteps.com'}
      expect(response.code).to eq("201")

      #and only one email sent
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end

    it 'should send an email to john doe' do
      post :generate_cert_and_send_email, { premium_identifier: Time.now.to_i, user_id: @user.id, price: 29, email: 'johndoe@chefsteps.com'}
      email = ActionMailer::Base.deliveries.first
      expect(email.to.first).to eq('johndoe@chefsteps.com')
    end

    it 'should have the correct email subject' do
      post :generate_cert_and_send_email, { premium_identifier: Time.now.to_i, user_id: @user.id, price: 29, email: 'johndoe@chefsteps.com'}
      email = ActionMailer::Base.deliveries.first
      expect(email.subject).to eq("ChefSteps Premium Gift Certificate")
    end

  end

end








