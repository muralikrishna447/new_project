require 'spec_helper'

describe Activity, 'publishing' do
  let!(:public_activity) { Fabricate(:activity, id: 1, published: true) }
  let!(:private_activity) { Fabricate(:activity, id: 2) }

  its "published flag is set to false by default" do
    private_activity.should_not be_published
  end

  its "published scope returns published activities only" do
    Activity.published.all.should == [public_activity]
  end

  context '#find_published' do
    it 'throws not found if activity does not exist with id' do
      lambda { Activity.find_published(42) }.should raise_error ActiveRecord::RecordNotFound
    end

    it 'returns activity if published' do
      Activity.find_published(1).should == public_activity
    end

    context 'for private activity' do
      it 'throws not found' do
        lambda { Activity.find_published(2) }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'throws not found if token is invalid' do
        PrivateToken.should_receive(:valid?).with('bad_token').and_return(false)
        lambda { Activity.find_published(2, 'bad_token') }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'returns activity if token is valid' do
        PrivateToken.should_receive(:valid?).with('good_token').and_return(true)
        Activity.find_published(2, 'good_token').should == private_activity
      end
    end
  end
end

