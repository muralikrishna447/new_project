# Just a place to play test out code with the ChefSteps application stack

class PlaygroundController < ApplicationController

  def index
    @activity = Activity.find 'beef-tartare'
  end

end