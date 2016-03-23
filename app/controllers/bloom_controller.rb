class BloomController < ApplicationController

  def index
  end

  def forum
    render layout: false
  end

  def betainvite
    render layout: false
  end

  # Endpoint for Bloom
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

  # Endpoint for Bloom
  def content
    bloom_id = params[:id]
    if bloom_id
      name_id = bloom_id.rpartition('_')
      name = name_id.first.split('_').map{|a| a.capitalize}.join('')
      id = name_id.last
      content = name.constantize.find(id)
      render json: content, serializer: "Content#{name}Serializer".constantize
    end
  end
end
