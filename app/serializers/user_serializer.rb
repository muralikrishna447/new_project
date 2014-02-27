class UserSerializer < ActiveModel::Serializer
  attributes :id, :bio, :chef_type, :created_at, :email, :google_access_token, :google_refresh_token, :google_user_id, :image_id, :level, :location, :name, :provider, :quote, :referred_from, :referrer_id, :role, :sash_id, :signed_up_from, :survey_results, :uid, :updated_at, :viewed_activities, :website, :authentication_token
  has_many :enrollments

  def authentication_token
    object.authentication_token
  end

end