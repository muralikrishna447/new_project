class UserPresenter < Presenter

  def present
    HashWithIndifferentAccess.new({
      id: @model.id,
      name: @model.name,
      email: @model.email,
      location: @model.location,
      website: @model.website,
      quote: @model.quote,
      profile_complete: @model.profile_complete?,
      image: profile_image_url,
    }).to_json
  end

  def profile_image_url
    if @model.connected_with_facebook?
      facebook_image_url(@model.uid)
    else
      @model.gravatar_url(default: default_profile_photo_url)
    end
  end

  def profile_edit_url
    @model.connected_with_facebook? ? facebook_edit_url : gravatar_edit_url
  end

  def facebook_image_url(uid)
    "https://graph.facebook.com/#{uid}/picture"
  end

  def facebook_edit_url
    "https://www.facebook.com"
  end

  def gravatar_edit_url
    "https://en.gravatar.com/site/signup/"
  end

  def default_profile_photo_url
    ActionController::Base.new.view_context.asset_path("profile-placeholder.png")
  end
end

