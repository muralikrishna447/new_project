# Just a place to play test out code with the ChefSteps application stack

class PlaygroundController < ApplicationController
  http_basic_authenticate_with name: 'delve', password: 'howtochef22'
  layout 'playground'
  def index

  end

end