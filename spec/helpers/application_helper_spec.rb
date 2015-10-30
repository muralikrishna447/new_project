require 'spec_helper'

describe ApplicationHelper, "#is_current_user?" do
  let(:user) { mock('user') }

  subject{ helper.is_current_user?(user) }

  context "with no user signed in" do
    before { helper.stub(:current_user) { nil } }
    it { subject.should == false}
  end

  context "with different user signed in" do
    before { helper.stub(:current_user) { mock('other user') } }
    it { subject.should == false}
  end

  context "with same user signed in" do
    before { helper.stub(:current_user) { user } }
    it { subject.should == true }
  end
end

describe ApplicationHelper, "#conditional_cache" do
  it 'should cache if cache_unless is false' do
    helper.should_receive(:cache)
    helper.conditional_cache(['test'], cache_unless: false)
  end

  it 'should not cache if cache_unless is true' do
    helper.should_not_receive(:cache)
    helper.conditional_cache(['test'], cache_unless: true) { @run = true }
    @run.should == true
  end
end

describe ApplicationHelper, "body data" do
  it 'stores and retreives body data' do
    helper.add_body_data(foo: 'bar')
    helper.body_data.should == {foo: 'bar'}
  end

  it 'accumulates body data' do
    helper.add_body_data(foo: 'bar')
    helper.add_body_data(baz: 'bar')
    helper.body_data.should == {foo: 'bar', baz: 'bar'}
  end

  it 'returns {} if no body data has been set' do
    helper.body_data.should == {}
  end
end

describe ApplicationHelper do
  assembly = Fabricate :assembly, title: 'Test', description: 'Test Description'
  project = Fabricate :assembly, title: 'Test', description: 'Test Description', assembly_type: 'Project'

  it 'returns correct path for assemblies' do
    helper.assembly_type_path(assembly).split('/')[1].should == 'assemblies'
  end

  it 'returns correct path for projects' do
    helper.assembly_type_path(project).split('/')[1].should == 'projects'
  end
end

describe ApplicationHelper do

  it 'returns is_google true when referer is from google' do
    controller.request.env['HTTP_USER_AGENT'] = 'googlebot/'
    helper.is_google.should be_true
  end

  it 'returns is_google true when referer is from google' do
    controller.request.env['HTTP_REFERER'] = 'http://www.google.com'
    helper.is_google.should be_true
  end

  it 'returns is_google true when cs-referer is from google' do
    controller.request.env['HTTP_CS_REFERER'] = 'http://www.google.com'
    helper.is_google.should be_true
  end

  it 'returns is_google false when the request is not a bot or referer is google' do
    controller.request.env['HTTP_REFERER'] = 'http://www.chefsteps.com'
    helper.is_google.should be_false
  end

  it 'returns is_google false when the request is not a bot or referer is nothing' do
    controller.request.env['HTTP_REFERER'] = ''
    helper.is_google.should be_false
  end
end
