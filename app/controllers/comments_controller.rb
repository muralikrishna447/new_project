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

  # Used by Bloom Dashboard to get context
  def info
    commentsId = params['commentsId']
    @commentable = find_commentable(commentsId)
    if @commentable
      title = @commentable.title
      url = determine_url(@commentable)
      info = Hash.new
      info['title'] = title
      info['url'] = url
      render :json => JSON.generate(info)
    else
      render :nothing => true, status: 404
    end
  end

  # Used by Bloom
  def at
    search_params = params['search']
    search_term = '%' + search_params + '%'
    # results = Hash.new
    # @user_results = []
    # @recipe_results = []
    # @ingredient_results = []

    # users = User.search(search_term).records
    # users_elapsed_time = Benchmark.ms do
    #   @user_results = users.map{|user| {'name' => user.name, 'id' => user.id, 'username' => user.slug, 'avatarUrl' => user.avatar_url}}
    # end

    # recipes = Activity.search(search_term).records
    # recipes_elapsed_time = Benchmark.ms do
    #   @recipe_results = recipes.map{|recipe| {'name' => recipe.title, 'id' => recipe.id, 'avatarUrl' => recipe.avatar_url}}
    # end

    # ingredients = Ingredient.search(search_term).records
    # ingredients_elapsed_time = Benchmark.ms do
    #   @ingredient_results = ingredients.map{|ingredient| {'name' => ingredient.title, 'id' => ingredient.id, 'avatarUrl' => ingredient.avatar_url}}
    # end

    # results['Users'] = @user_results
    # results['Recipes'] = @recipe_results
    # results['Ingredients'] = @ingredient_results

    # puts "User: #{users_elapsed_time}"
    # puts "Recipes: #{recipes_elapsed_time}"
    # puts "Ingredients: #{ingredients_elapsed_time}"

    # render :json => JSON.pretty_generate(results)

    results = Searchable.search(search_params)
    render :json => JSON.pretty_generate(results)
  end

private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id.to_i)
    puts '---------------'
    puts resource
  end

  def find_commentable(commentsId)
    pos = commentsId.rindex('_')
    if pos
      class_name = commentsId[0...pos]
      id = commentsId[pos+1..-1]
      class_name.gsub('_', ' ').titleize.gsub(' ','').singularize.classify.constantize.find(id)
    end
  end

  def determine_url(commentable)
    if commentable.class.to_s == 'PollItem'
      "#{request.base_url}/polls/#{commentable.poll.slug}"
    else
      polymorphic_url(commentable)
    end
  end

end