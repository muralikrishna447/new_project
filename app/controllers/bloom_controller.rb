class BloomController < ApplicationController
  def index

  end

  def forum
    puts 'THIS IS THE CURRENT USER: '
    puts current_user
    puts '*******'
    render layout: false
  end
end