class Ability
  include CanCan::Ability

  # We still have separate user and admin user models. This should go away at some point, but
  # for now if someone is logged in on the backend, they are automagically treated as an admin.
  def initialize(user, admin_user)
    user ||= User.new # guest user (not logged in)
    if (user.role? :admin) || admin_user
      can :manage, :all
    else
      can :read, :all
    end
  end
end
