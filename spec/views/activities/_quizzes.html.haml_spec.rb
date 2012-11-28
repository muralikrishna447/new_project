require 'spec_helper'

describe 'activities/_quizzes.html.haml' do
  let(:activity) { stub('activity', has_quizzes?: @has_quizzes, quizzes: []) }
  before { @has_quizzes = true }

  it 'does not render if quizzes are not shown' do
    view.stub(:show_quizzes?) { false }
    render 'quizzes', activity: activity
    rendered.should be_blank
  end

  it 'does not render if activity has no quizzes' do
    @has_quizzes = false
    view.stub(:show_quizzes?) { true }
    render 'quizzes', activity: activity
    rendered.should be_blank
  end

  it 'renders if quizzes are shown and activity has quizzes' do
    view.stub(:show_quizzes?) { true }
    render 'quizzes', activity: activity
    rendered.should have_content 'Quizzes'
  end
end
