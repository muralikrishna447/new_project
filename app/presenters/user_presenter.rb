class UserPresenter < Presenter
  def attributes
    {
      id: @model.id,
      slug: @model.slug,
      name: @model.name,
      email: @model.email,
      location: @model.location,
      website: @model.website,
      quote: @model.quote,
      chef_type: @model.chef_type,
      profile_complete: @model.profile_complete?,
      image: profile_image_url,
    }
  end

  def profile_image_url
    if @model.connected_with_facebook?
      UserPresenter.facebook_image_url(@model.facebook_user_id)
    else
      @model.gravatar_url(default: default_profile_photo_url)
    end
  end

  def profile_edit_url
    @model.connected_with_facebook? ? facebook_edit_url : gravatar_edit_url
  end

  def self.facebook_image_url(uid)
    "https://graph.facebook.com/#{uid}/picture?type=large"
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

