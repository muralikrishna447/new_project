require 'spec_helper'

describe QuestionPresenter, "#present" do
  let(:question) { Fabricate.build(:multiple_choice_question) }
  let(:question_presenter) { QuestionPresenter.new(question) }

  subject { JSON.parse(question_presenter.present) }

  it "serializes valid keys" do
    subject.keys.should =~ %w[id]
  end
end

