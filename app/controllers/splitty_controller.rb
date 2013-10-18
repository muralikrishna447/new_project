class SplittyController < ApplicationController
  def finish_split
    finished(params[:experiment], reset: false)
    puts "FININSHING #{params[:experiment]}"
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end
end

