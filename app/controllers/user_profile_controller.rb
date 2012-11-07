class UserProfileController < ApplicationController
  expose(:user) { current_user }

end

