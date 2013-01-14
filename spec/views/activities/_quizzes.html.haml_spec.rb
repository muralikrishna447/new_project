require 'spec_helper'

describe 'activities/_quizzes.html.haml' do
  let(:activity) { stub('activity', has_quizzes?: @has_quizzes, quizzes: []) }
  before { @has_quizzes = true }


  it 'does not render if activity has no quizzes' do
    @has_quizzes = false
    render 'quizzes', activity: activity
    rendered.should be_blank
  end

  it 'renders if activity has quizzes' do
    render 'quizzes', activity: activity
    rendered.should_not be_blank
  end
end
