require 'spec_helper'

describe User do
  before do
    @user = Fabricate(:user)
    @assembly = Fabricate(:assembly, price: 20.00)
  end

  context "#enrolled?" do
    context "normal enrollment" do
      it "should return true if enrollment exists" do
        Fabricate(:enrollment, user_id: @user.id, enrollable: @assembly)
        @user.enrolled?(@assembly).should be true
      end

      it "should return false if enrollment doesn't exist" do
        @user.enrolled?(@assembly).should be false
      end
    end
  end

  context "tokens" do
    it 'should return a valid auth token when no actor address exists' do
      token = @user.valid_website_auth_token
      aa = ActorAddress.find_for_user_and_unique_key(@user, 'website')
      aa.valid_token?(token).should be true
      # TODO - use timecop to avoid time hacks like this - 5
      token[:exp].should >= (Time.now.to_i + 365.days.to_i)
    end

    it 'should return a valid auth token when no actor address exists' do
      aa = ActorAddress.create_for_user(@user, unique_key: 'website')
      token = @user.valid_website_auth_token
      token.claim[:a].should == aa.address_id
      aa.valid_token?(token).should be true
    end
  end

  context "premium member" do
    it "should default false" do
      @user.premium?.should be false
    end

    it "make_premium_member should set correct fields" do
      @user.make_premium_member(10)
      @user.premium?.should be true
      @user.premium_membership_created_at.should be > DateTime.now - 1.hour
      expect(@user.premium_membership_price).to eq(10)
    end

    it 'make_premium should enqueue user sync job' do
      Resque.should_receive(:enqueue).with(UserSync, @user.id)
      @user.make_premium_member(10)
    end

  end

  context "joule_purchased" do
    it "should set date and count on first purchase" do
      @user.joule_purchase_count.should eq(0)
      @user.first_joule_purchased_at.present?.should be false

      @user.joule_purchased

      @user.first_joule_purchased_at.present?.should be true
      @user.joule_purchase_count.should eq(1)
    end

    it "should change count but not date on second purchase" do
      @user.joule_purchased
      date = @user.first_joule_purchased_at
      @user.joule_purchased
      @user.first_joule_purchased_at.should eq(date)
      @user.joule_purchase_count.should eq(2)
    end
  end

  context "use_premium_discount" do
    it "should set used_circulator_discount to true" do
      @user.use_premium_discount
      @user.used_circulator_discount.should eq true
    end
  end

  context "can_receive_circulator_discount" do
    it "should return true if the user is a premium member and hasn't used their discount" do
      @user.make_premium_member(10)
      @user.can_receive_circulator_discount?.should eq true
    end

    it 'should return false if the user has used their discount' do
      @user.make_premium_member(10)
      @user.use_premium_discount
      @user.can_receive_circulator_discount?.should eq false
    end
  end

  context 'merge user' do
    let(:user_role) { 'user' }
    let(:admin_role) { 'admin' }

    let(:master_user_name) { 'Master Name' }
    let(:master_user_location) { 'Master Location' }
    let(:master_user_quote) { 'Master Quote' }
    let(:master_user_website) { 'Master Website' }
    let(:master_user_chef_type) { 'other' }
    let(:master_user_from_aweber) { true }
    let(:master_user_signed_up_from) { 'Master Signed Up From' }
    let(:master_user_bio) { 'Master Bio' }
    let(:master_user_image_id) { 'Master Image Id' }
    let(:master_user_referred_from) { 'Master Referred From' }
    let(:master_user_referrer_id) { 1 }
    let(:master_user_survey_results) { { 'master' => true } }
    let(:master_user_skip_name_validation) { true }
    let(:master_user) do
      Fabricate(
        :user,
        name: master_user_name,
        location: master_user_location,
        quote: master_user_quote,
        website: master_user_website,
        chef_type: master_user_chef_type,
        from_aweber: master_user_from_aweber,
        signed_up_from: master_user_signed_up_from,
        bio: master_user_bio,
        image_id: master_user_image_id,
        referred_from: master_user_referred_from,
        referrer_id: master_user_referrer_id,
        survey_results: master_user_survey_results,
        skip_name_validation: master_user_skip_name_validation
      )
    end

    let(:merged_user_name) { 'Merged Name' }
    let(:merged_user_location) { 'Merged Location' }
    let(:merged_user_quote) { 'Merged Quote' }
    let(:merged_user_website) { 'Merged Website' }
    let(:merged_user_chef_type) { 'home_cook' }
    let(:merged_user_from_aweber) { true }
    let(:merged_user_signed_up_from) { 'Merged Signed Up From' }
    let(:merged_user_bio) { 'Merged User Bio' }
    let(:merged_user_image_id) { 'Merged Image Id' }
    let(:merged_user_referred_from) { 'Merged Referred From' }
    let(:merged_user_referrer_id) { 2 }
    let(:merged_user_survey_results) { { 'merged' => true } }
    let(:merged_user_skip_name_validation) { true }
    let(:user_to_merge) do
      Fabricate(
        :user,
        name: merged_user_name,
        location: merged_user_location,
        quote: merged_user_quote,
        website: merged_user_website,
        chef_type: merged_user_chef_type,
        from_aweber: merged_user_from_aweber,
        signed_up_from: merged_user_signed_up_from,
        bio: merged_user_bio,
        image_id: merged_user_image_id,
        referred_from: merged_user_referred_from,
        referrer_id: merged_user_referrer_id,
        survey_results: merged_user_survey_results,
        skip_name_validation: merged_user_skip_name_validation
      )
    end

    context 'merged and master properties are not blank' do
      it 'preserves all properties' do
        master_user.merge(user_to_merge)
        expect(master_user.name).to eq(master_user_name), 'name'
        expect(master_user.location).to eq(master_user_location), 'location'
        expect(master_user.quote).to eq(master_user_quote), 'quote'
        expect(master_user.website).to eq(master_user_website), 'website'
        expect(master_user.chef_type).to eq(master_user_chef_type), 'chef_type'
        expect(master_user.signed_up_from).to eq(master_user_signed_up_from), 'signed_up_from'
        expect(master_user.bio).to eq(master_user_bio), 'bio'
        expect(master_user.image_id).to eq(master_user_image_id), 'image_id'
        expect(master_user.referred_from).to eq(master_user_referred_from), 'referred_from'
        expect(master_user.referrer_id).to eq(master_user_referrer_id), 'referrer_id'
        expect(master_user.survey_results).to eq(master_user_survey_results), 'survey_results'
      end
    end

    context 'master properties are blank' do
      let(:master_user) { User.new }

      it 'sets the master property to the merged value' do
        master_user.merge(user_to_merge)
        expect(master_user.name).to eq(merged_user_name), 'name'
        expect(master_user.location).to eq(merged_user_location), 'location'
        expect(master_user.quote).to eq(merged_user_quote), 'quote'
        expect(master_user.website).to eq(merged_user_website), 'website'
        expect(master_user.chef_type).to eq(merged_user_chef_type), 'chef_type'
        expect(master_user.signed_up_from).to eq(merged_user_signed_up_from), 'signed_up_from'
        expect(master_user.bio).to eq(merged_user_bio), 'bio'
        expect(master_user.image_id).to eq(merged_user_image_id), 'image_id'
        expect(master_user.referred_from).to eq(merged_user_referred_from), 'referred_from'
        expect(master_user.referrer_id).to eq(merged_user_referrer_id), 'referrer_id'
        expect(master_user.survey_results).to eq(merged_user_survey_results), 'survey_results'
      end
    end

    context 'merged and master booleans are true' do
      let(:master_user) do
        Fabricate(:user, from_aweber: true, skip_name_validation: true)
      end
      let(:user_to_merge) do
        Fabricate(:user, from_aweber: true, skip_name_validation: true)
      end

      it 'preserves booleans' do
        master_user.merge(user_to_merge)
        expect(master_user.from_aweber).to be_true, 'from_aweber'
        expect(master_user.skip_name_validation).to be_true, 'skip_name_validation'
      end
    end

    context 'merged booleans are true and master booleans are false' do
      let(:master_user) do
        Fabricate(:user, from_aweber: false, skip_name_validation: false)
      end
      let(:user_to_merge) do
        Fabricate(:user, from_aweber: true, skip_name_validation: true)
      end

      it 'sets booleans to true' do
        master_user.merge(user_to_merge)
        expect(master_user.from_aweber).to be_true, 'from_aweber'
        expect(master_user.skip_name_validation).to be_true, 'skip_name_validation'
      end
    end

    context 'master does not have merged role' do
      let(:master_user) { Fabricate(:user, role: user_role) }
      let(:user_to_merge) { Fabricate(:user, role: admin_role) }

      it 'sets the role to the merged value' do
        master_user.merge(user_to_merge)
        master_user.role.should eq admin_role
      end
    end

    context 'master already has merged role' do
      let(:master_user) { Fabricate(:user, role: admin_role) }
      let(:user_to_merge) { Fabricate(:user, role: user_role) }

      it 'preserves the master role' do
        master_user.merge(user_to_merge)
        master_user.role.should eq admin_role
      end
    end

    context 'premium' do
      let(:premium_membership_price) { 10 }
      let(:premium_membership_created_at) { DateTime.new(2016, 8, 10) }

      context 'master is premium and merged is not premium' do
        let(:master_user) do
          Fabricate(
            :user,
            premium_member: true,
            premium_membership_price: premium_membership_price,
            premium_membership_created_at: premium_membership_created_at
          )
        end
        let(:user_to_merge) { Fabricate(:user, premium_member: false) }

        it 'preserves premium in master' do
          master_user.merge(user_to_merge)
          master_user.premium_member.should eq true
          master_user.premium_membership_price.should eq premium_membership_price
          master_user.premium_membership_created_at.should eq premium_membership_created_at
        end
      end

      context 'master is not premium and merged is premium' do
        let(:master_user) { Fabricate(:user, premium_member: false) }
        let(:user_to_merge) do
          Fabricate(
            :user,
            premium_member: true,
            premium_membership_price: premium_membership_price,
            premium_membership_created_at: premium_membership_created_at
          )
        end

        it 'sets premium on master' do
          master_user.merge(user_to_merge)
          master_user.premium_member.should eq true
          master_user.premium_membership_price.should eq premium_membership_price
          master_user.premium_membership_created_at.should eq premium_membership_created_at
        end
      end

      context 'master and merged are not premium' do
        let(:master_user) { Fabricate(:user, premium_member: false) }
        let(:user_to_merge) { Fabricate(:user, premium_member: false) }

        it 'preserves no premium on master' do
          master_user.merge(user_to_merge)
          master_user.premium_member.should eq false
        end
      end
    end

    context 'merged user has relations' do
      context 'merged user has uploads' do
        let(:master_user) { Fabricate(:user) }
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.uploads = [
            Fabricate(:upload, user_id: user.id),
            Fabricate(:upload, user_id: user.id)
          ]
          user
        end

        it 'merges uploads to master user' do
          master_user.merge(user_to_merge)
          expect(master_user.uploads).to match_array(user_to_merge.uploads)
        end
      end

      context 'merged user has events' do
        let(:master_user) { Fabricate(:user) }
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.events = [
            Fabricate(:event, user_id: user.id),
            Fabricate(:event, user_id: user.id)
          ]
          user
        end

        it 'merges events to master user' do
          master_user.merge(user_to_merge)
          expect(master_user.events).to match_array(user_to_merge.events)
        end
      end

      context 'merged user has likes not in master user' do
        let(:master_user) { Fabricate(:user) }
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.likes = [
            Fabricate(:like, user_id: user.id, likeable_id: 1),
            Fabricate(:like, user_id: user.id, likeable_id: 2)
          ]
          user
        end

        it 'merges likes to the master user' do
          master_user.merge(user_to_merge)
          master_user.likes.reload
          expect(master_user.likes).to match_array(user_to_merge.likes)
        end
      end

      context 'merged user has likes also in master user' do
        let(:likeable_id_1) { 1 }
        let(:likeable_id_2) { 2 }
        let(:master_user) do
          user = Fabricate(:user)
          user.likes = [
            Fabricate(:like, user_id: user.id, likeable_id: likeable_id_1)
          ]
          user
        end
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.likes = [
            Fabricate(:like, user_id: user.id, likeable_id: likeable_id_1),
            Fabricate(:like, user_id: user.id, likeable_id: likeable_id_2)
          ]
          user
        end

        it 'dedupes common likes' do
          master_user.merge(user_to_merge)
          master_user.likes.reload
          master_user.likes.sort_by!(&:likeable_id)
          expect(master_user.likes.first.likeable_id).to eq likeable_id_1
          expect(master_user.likes.second.likeable_id).to eq likeable_id_2
          expect(master_user.likes.size).to eq 2
        end
      end

      context 'merged user has created activities' do
        let(:master_user) { Fabricate(:user) }
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.created_activities = [
            Fabricate(:activity, creator: user),
            Fabricate(:activity, creator: user)
          ]
          user
        end

        it 'merges activities to master user' do
          master_user.merge(user_to_merge)
          expect(master_user.created_activities).to match_array(user_to_merge.created_activities)
        end
      end

      context 'merged user has purchased premium gift certificates' do
        let(:master_user) { Fabricate(:user) }
        let(:user_to_merge) { Fabricate(:user) }
        let(:premium_gift_certificates) do
          [
            Fabricate(:premium_gift_certificate, purchaser_id: user_to_merge.id),
            Fabricate(:premium_gift_certificate, purchaser_id: user_to_merge.id)
          ]
        end

        before { premium_gift_certificates.each(&:save) }

        it 'merges premium gift certificates to master user' do
          master_user.merge(user_to_merge)
          expect(PremiumGiftCertificate.where(purchaser_id: user_to_merge.id)).to be_empty
          expect(PremiumGiftCertificate.where(purchaser_id: master_user.id)).to match_array premium_gift_certificates
        end
      end

      context 'merged user has circulator_users not in master user' do
        let(:master_user) { Fabricate(:user) }
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.circulator_users = [
            Fabricate(:circulator_user, user_id: user.id, circulator_id: 1),
            Fabricate(:circulator_user, user_id: user.id, circulator_id: 2)
          ]
          user
        end

        it 'merges circulator_users to the master user' do
          master_user.merge(user_to_merge)
          master_user.circulator_users.reload
          expect(master_user.circulator_users).to match_array(user_to_merge.circulator_users)
        end
      end

      context 'merged user has circulator_users also in master user' do
        let(:circulator_id_1) { 1 }
        let(:circulator_id_2) { 2 }
        let(:master_user) do
          user = Fabricate(:user)
          user.circulator_users = [
            Fabricate(:circulator_user, user_id: user.id, circulator_id: circulator_id_1)
          ]
          user
        end
        let(:user_to_merge) do
          user = Fabricate(:user)
          user.circulator_users = [
            Fabricate(:circulator_user, user_id: user.id, circulator_id: circulator_id_1),
            Fabricate(:circulator_user, user_id: user.id, circulator_id: circulator_id_2)
          ]
          user
        end

        it 'dedupes common circulator_users' do
          master_user.merge(user_to_merge)
          master_user.circulator_users.reload
          master_user.circulator_users.sort_by!(&:circulator_id)
          expect(master_user.circulator_users.first.circulator_id).to eq circulator_id_1
          expect(master_user.circulator_users.second.circulator_id).to eq circulator_id_2
          expect(master_user.circulator_users.size).to eq 2
        end
      end
    end
  end
end
