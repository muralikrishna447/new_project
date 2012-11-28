class QuizzesController < ApplicationController
  before_filter :authenticate_user!

  expose(:quiz)
end
