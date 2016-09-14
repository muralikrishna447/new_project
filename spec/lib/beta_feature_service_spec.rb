require 'spec_helper'

describe BetaFeatureService do

  def set_user_groups(user, groups)
    throw Error.new("Need a user") unless user
    BetaFeature::DynamoBetaFeatureService.any_instance \
      .stub(:get_groups_for_user) \
      .with(user) \
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
    # By default, return nothing
    BetaFeature::DynamoBetaFeatureService.any_instance \
      .stub(:get_groups_for_user) \
      .and_return([])
    BetaFeature::DynamoBetaFeatureService.any_instance \
      .stub(:get_feature_group_info) \
      .and_return([])
    BetaFeature::DynamoBetaFeatureService.any_instance \
      .stub(:get_feature_info) \
      .and_return(nil)

    @user1 = User.new({:name => "RZA", :email => 'rza@b.com', :password => '123456'})
    @user1.save!
    @user2 = User.new({:name => "GZA", :email => 'gza@b.com', :password => '123456'})
    @user2.save!
  end

  it 'respects group rules' do
    set_user_groups(@user1, ['dev'])
    set_feature_groups(
      'dfu',
      [
        {'group_name' => 'dev', 'feature_name' => 'dfu', 'is_enabled' => true},
        {'group_name' => 'reviewers', 'feature_name' => 'dfu', 'is_enabled' => false},
      ]
    )
    is_enabled = BetaFeatureService.user_has_feature(@user1, 'dfu')
    expect(is_enabled).to eq(true)
  end

end
