require 'spec_helper'

describe CommentsController do
  before :each do
    @controller = CommentsController.new
    Fabricate :activity, id: '123', title: 'Activity', description: 'description', published: true
    Fabricate :upload, id: '123', title: 'Upload'
    Fabricate :poll_item, id: '123', title: 'Poll Item'
    Fabricate :ingredient, id: '123', title: 'Ingredient'
  end

  describe 'find_commentable' do
    it 'returns an Activity object when given a commentsId of format activity_id' do
      activity = @controller.instance_eval{ find_commentable('activity_123') }
      activity.class.to_s.should eq('Activity')
    end

    it 'returns an Upload object when given a commentsId of format activity_id' do
      upload = @controller.instance_eval{ find_commentable('upload_123') }
      upload.class.to_s.should eq('Upload')
    end

    it 'returns an PollItem object when given a commentsId of format activity_id' do
      poll_item = @controller.instance_eval{ find_commentable('poll_item_123') }
      poll_item.class.to_s.should eq('PollItem')
    end

    it 'returns an Ingredient object when given a commentsId of format activity_id' do
      ingredient = @controller.instance_eval{ find_commentable('ingredient_123') }
      ingredient.class.to_s.should eq('Ingredient')
    end
  end

end
