class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if (user.role? :admin)
      can :manage, :all
    elsif (user.role? :contractor)
      can :read, :all
    elsif (user.role? :moderator)
      can :manage, Activity
      can :manage, Ingredient
    elsif (user.role? :collaborator)
      can :manage, Activity
      can :manage, Ingredient
      can :manage, Assembly
    else
      can :manage, Activity, user: user
      can :create, Activity
      can :create, Ingredient
      can :update, Ingredient
      can :read, :all
    end
  end
end
