require 'spec_helper'

describe ForumSSOController do

  # If the register url parameter is set to "1", send the user to your register/signup page, and then back to this same URL.
  # If the user is not signed in, send them to your signin page, and then back to this same URL.
  # build a URL encoded HTTP query string of the required parameters (exclude the question mark)
  # Compute the SHA1 hash of your SSO secret appended to the end of the query string. Note: the secret should NOT be sent in the query string.
  # Append &hash=abcd01234... to end end of your query string
  # Redirect the user to the URL: http://forum.chefsteps.com/Guide/User/remote_login with your query string from above appended to the end.
  it 'has a route' do
    get :authenticate
  end

end
