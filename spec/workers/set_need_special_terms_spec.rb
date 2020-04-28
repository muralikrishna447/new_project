describe SetNeedsSpecialTerms do
  before :each do
    @user_id = 100
    @user = Fabricate :user, id: @user_id, email: 'johndoe@chefsteps.com'
  end

  it 'should double increment all actors' do
    aa_one = ActorAddress.create_for_user(@user)
    aa_two = ActorAddress.create_for_user(@user)
    
    SetNeedsSpecialTerms.perform(@user.email)
    expect(@user.reload.needs_special_terms).to be true
    
    aa_one.reload.sequence.should == 2
    aa_two.reload.sequence.should == 2
  end

  it 'should not crash if no actors exist' do
    SetNeedsSpecialTerms.perform(@user.email)
    expect(@user.reload.needs_special_terms  ).to be true
  end

  it 'should raise with invalid email' do
    expect { SetNeedsSpecialTerms.perform('me@example.com') }.to raise_exception
  end
end
