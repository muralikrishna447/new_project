class Users::RegistrationsController < Devise::RegistrationsController
  append_after_filter :aweber_signup, :only => :create

  protected
  def build_resource(hash=nil)
    hash ||= resource_params || {}
    self.resource = resource_class.new_with_session(hash, session)

    fb_data = session["devise.facebook_data"]
    self.resource.assign_from_facebook(fb_data) if fb_data
  end

  def aweber_signup
    if params[:ok_to_email]
      uri = URI.parse("http://www.aweber.com/scripts/addlead.pl")
      response = Net::HTTP.post_form(uri,
                                      { "email" => params[:user][:email],
                                        "name" => params[:user][:name],
                                        "listname" => "cs_c_sousvide",
                                        "meta_adtracking" => "cs_new_site_user"})
    end
  end
end

