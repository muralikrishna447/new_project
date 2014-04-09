class CommentsController < ApplicationController
  
  before_filter :authenticate_user!, only: [:create]
  before_filter :load_commentable, only: [:index, :create]

  def index
    @comments = @commentable.comments
    render :json => @comments.to_json(:include => :user)
  end

  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      render :json => @comment.to_json(:include => :user)
      track_event @comment
      track_receiver_event @comment
    end
  end

  # Used by Bloom
  def info
    split_id = params['commentsId'].split('_')
    resource = split_id[0]
    id = split_id[1]
    @commentable = resource.singularize.classify.constantize.find(id)
    title = @commentable.title
    url = polymorphic_url(@commentable)
    info = Hash.new
    info['title'] = title
    info['url'] = url
    render :json => JSON.generate(info)
  end

  # Used by Bloom
  def at
    search_params = params['search']
    search_term = '%' + search_params + '%'
    results = Hash.new

    user_results = []
    users = User.where("name iLIKE ?", search_term).order('events_count desc').limit(300)
    users.each do |user|
      user_results << {'name' => user.name, 'id' => user.id, 'username' => user.slug, 'avatarUrl' => user.avatar_url}
    end

    recipe_results = []
    recipes = Activity.chefsteps_generated.where("title iLIKE ?", search_term).order('likes_count desc').limit(300)
    recipes.each do |recipe|
      recipe_results << {'name' => recipe.title, 'id' => recipe.id, 'avatarUrl' => recipe.avatar_url}
    end

    ingredient_results = []
    ingredients = Ingredient.where("title iLIKE ?", search_term).order('created_at asc').limit(300)
    ingredients.each do |ingredient|
      ingredient_results << {'name' => ingredient.title, 'id' => ingredient.id, 'avatarUrl' => ingredient.avatar_url}
    end

    results['Users'] = user_results
    results['Recipes'] = recipe_results
    results['Ingredients'] = ingredient_results
    render :json => JSON.pretty_generate(results)
  end

private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id.to_i)
    puts '---------------'
    puts resource
  end

end