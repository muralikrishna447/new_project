require 'spec_helper'

describe 'activities/_quizzes.html.haml' do
  let(:activity) { stub('activity', has_quizzes?: @has_quizzes) }
  before { @has_quizzes = true }

  it 'does not render if show_quiz? is false' do
    view.stub(:show_quiz?) { false }
    render 'quizzes', activity: activity
    rendered.should be_blank
  end

  it 'does not render if activity has no quizzes' do
    @has_quizzes = false
    view.stub(:show_quiz?) { true }
    render 'quizzes', activity: activity
    rendered.should be_blank
  end

  it 'renders if show_quiz? is true and activity has quizzes' do
    view.stub(:show_quiz?) { true }
    render 'quizzes', activity: activity
    rendered.should have_content 'Quizzes'
  end
end
