class BloomController < ApplicationController
  def index

  end

  def forum
    if current_user
      render layout: false
    else
      redirect_to(sign_in_path(returnTo: '/forum'), notice: "You must be signed in to view the Forum")
    end
  end

  def betainvite
    render layout: false
  end

  def content_discussion
    # Redirects notifs to the proper content
    bloom_id = params[:id]
    if bloom_id
      name_id = bloom_id.rpartition('_')
      name = name_id.first.pluralize
      id = name_id.last
      url = "/#{name}/#{id}#discussion"
      redirect_to url
      # redirect_to "/activities/nick-cammarata-s-version-of-foie-gras-ganache?hello=true"
    end
  end
end