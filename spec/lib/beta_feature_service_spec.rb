require 'spec_helper'

describe BetaFeatureService do

  def set_user_groups(groups)
    BetaFeature::DynamoBetaFeatureService.any_instance.stub(:get_groups_for_user) \
      .and_return(groups)
  end

  def set_feature_groups(feature_name, feature_groups)
    for fg in feature_groups
      throw Error.new("bad feature name") if fg['feature_name'] != feature_name
    end
    BetaFeature::DynamoBetaFeatureService.any_instance.stub(:get_feature_group_info) \
      .and_return(feature_groups)
  end

  before :each do
    @user = User.new({:name => "Bob Hope", :email => 'a@b.com', :password => '123456'})
    @user.save!
  end

  it 'respects group rules' do
    set_user_groups(['dev'])
    set_feature_groups(
      'dfu',
      [
        {'group_name' => 'dev', 'feature_name' => 'dfu', 'is_enabled' => true},
        {'group_name' => 'reviewers', 'feature_name' => 'dfu', 'is_enabled' => false},
      ]
    )
    is_enabled = BetaFeatureService.user_has_feature(@user, 'dfu')
    expect(is_enabled).to eq(true)
  end

end
