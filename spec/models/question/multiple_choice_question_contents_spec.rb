require 'spec_helper'

describe MultipleChoiceQuestionContents, '#update' do
  let(:contents) { MultipleChoiceQuestionContents.new }
  let(:content_attributes) { { question: 'question stuff', instructions: 'instruction stuff',
                       options: [{title: 'option 1'}, {title: 'option 2'}] } }
  let(:params) { {foo: 'bar'}.merge(content_attributes) }

  it "updates question" do
    contents.update(params)
    contents.question.should == 'question stuff'
  end

  it "updates instructions" do
    contents.update(params)
    contents.instructions.should == 'instruction stuff'
  end

  it "updates options" do
    contents.update(params)
    contents.options.should have(2).options
  end

  context 'unique option ids' do
    before { contents.stub(:unique_id) { 'abcd' } }

    it 'generates unique id for each option if id not present' do
      contents.update(params)
      contents.options.first[:uid].should == 'abcd'
      contents.options.last[:uid].should == 'abcd'
    end

    it 'uses unique id from option if present in params' do
      params[:options].first[:uid] = 'efgh'
      contents.update(params)
      contents.options.first[:uid].should == 'efgh'
      contents.options.last[:uid].should == 'abcd'
    end
  end
end

describe MultipleChoiceQuestionContents, '#to_json' do
  let(:admin) { false }
  let(:contents) { Fabricate.build(:multiple_choice_question_contents) }

  subject { contents.to_json(admin) }

  its(:keys) { should =~ [:question, :options] }

  it 'excludes correct flag from options' do
    options_correct?.should_not be
  end

  context 'admin flag is true' do
    let(:admin) { true }
    it 'excludes correct flag from options' do
      options_correct?.should be
    end
  end

  def options_correct?
    subject[:options].any?{|o| o[:correct]}
  end
end

describe MultipleChoiceQuestionContents, '#correct' do
  let(:contents) { Fabricate.build(:multiple_choice_question_contents) }
  let(:answer) { Fabricate.build(:multiple_choice_answer_contents, uid: 'id-answer-1') }

  it 'returns true if answer matches correct option' do
    contents.correct(answer).should be_true
  end

  it 'returns false if answer does not match correct option' do
    answer.uid = 'id-answer-2'
    contents.correct(answer).should be_false
  end

  it 'returns false if answer cannot be found in options' do
    answer.uid = 'invalid-id'
    contents.correct(answer).should be_false
    answer.delete_field(:uid)
    contents.correct(answer).should be_false
  end
end

describe MultipleChoiceQuestionContents, '#unique_id' do
  let(:contents) { Fabricate.build(:multiple_choice_question_contents) }

  it 'calls SecureRandom#uuid' do
    SecureRandom.should_receive(:uuid)
    contents.send(:unique_id)
  end
end

describe MultipleChoiceQuestionContents, "#option_display" do
  let(:mc_contents) { Fabricate.build(:multiple_choice_question_contents) }
  let(:tf_contents) { Fabricate.build(:true_false_question_contents) }

  it 'returns nil if uid matches no option' do
    mc_contents.option_display('bad-uid').should_not be
  end

  it 'returns letter of option specified by uid for multiple choice contents' do
    mc_contents.option_display('id-answer-1').should == 'a'
    mc_contents.option_display('id-answer-2').should == 'b'
  end

  it 'returns true/false value of option specified by uid for multiple choice contents' do
    tf_contents.option_display('id-answer-1').should == 'True'
    tf_contents.option_display('id-answer-2').should == 'False'
  end
end

describe MultipleChoiceQuestionContents, "#correct_option_display" do
  let(:mc_contents) { Fabricate.build(:multiple_choice_question_contents) }

  it 'calls option_display with uid of correct option' do
    mc_contents.should_receive(:option_display).with('id-answer-1') { 'a' }
    mc_contents.correct_option_display.should == 'a'
  end
end
