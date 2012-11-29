require 'spec_helper'

describe QuestionPresenter, "#present" do
  let(:question) { Fabricate.build(:multiple_choice_question) }
  let(:question_presenter) { QuestionPresenter.new(question) }

  subject { question_presenter.attributes }

  it "serializes valid keys" do
    subject.keys.should =~ [:id, :question_order]
  end
end

