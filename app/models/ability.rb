class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if (user.role? :admin)
      can :manage, :all
    elsif (user.role? :moderator)
      can :manage, Activity
    else
      can :manage, Activity, creator: user
      can :create, Activity
      can :read, :all
    end
  end
end
