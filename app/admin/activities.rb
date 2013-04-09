# https://gist.github.com/agius/2631752
def json_differences(a, b)
  return [a.class.name, nil] if !a.nil? && b.nil?
  return [nil, b.class.name] if !b.nil? && a.nil?

  differences = {}
  a.each do |k, v|
    if !v.nil? && b[k].nil?
      differences[k] = [v, nil]
      next
    elsif !b[k].nil? && v.nil?
      differences[k] = [nil, b[k]]
      next
    end

    if v.is_a?(Hash)
      unless b[k].is_a?(Hash)
        differences[k] = "Different types"
        next
      end
      diff = json_differences(a[k], b[k])
      differences[k] = diff if !diff.nil? && diff.count > 0

    elsif v.is_a?(Array)
      unless b[k].is_a?(Array)
        differences[k] = "Different types"
        next
      end

      c = 0
      diff = v.map do |n|
        if n.is_a?(Hash)
          diffs = json_differences(n, b[k][c])
          c += 1
          ["Differences: ", diffs] unless diffs.nil?
        else
          c += 1
          [n , b[c]] unless b[c] == n
        end
      end.compact

      differences[k] = diff if diff.count > 0

    else
      differences[k] = [v, b[k]] unless v == b[k]

    end
  end

  return differences if !differences.nil? && differences.count > 0
end


ActiveAdmin.register Activity do
  config.sort_order = 'activity_order_asc'

  menu priority: 2

  action_item only: [:show, :edit] do
    link_to_publishable activity, 'View on Site'
  end

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  action_item only: [:show, :edit] do
    link_to('Edit Step Ingredients', associated_ingredients_admin_activity_path(activity))
  end

  action_item only: [:show] do
    link_to('Versions', versions_admin_activity_path(activity))
  end


  index do
    column 'Link' do |activity|
      link_to_publishable(activity)
    end
    column :title, sortable: :title do |activity|
      activity.title.html_safe
    end
    column :difficulty
    column :yield
    column "Description" do |activity|
      truncate(activity.description, length: 50)
    end
    column :published
    default_actions
  end

  controller do
    def create
      equipment_attrs = separate_equipment
      step_attrs = separate_steps
      ingredient_attrs = separate_ingredients
      @activity = Activity.create(params[:activity])
      @activity.update_equipment(equipment_attrs)
      @activity.update_steps(step_attrs)
      @activity.update_ingredients(ingredient_attrs)
      create!
    end

    def update
      @activity = Activity.find(params[:id])
      @activity.store_revision do
        @activity.update_equipment(separate_equipment)
        @activity.update_steps(separate_steps)
        @activity.update_ingredients(separate_ingredients)
        update!
      end
    end

    private

    def separate_equipment
      params[:activity].delete(:equipment)
    end

    def separate_steps
      params[:activity].delete(:steps)
    end

    def separate_ingredients
      params[:activity].delete(:ingredients)
    end
  end

  collection_action :activities_order, method: :get do
    @activities = Activity.ordered.all
  end

  collection_action :update_activities_order, method: :post do
    params[:activity_ids].each do |activity_id|
      activity = Activity.find(activity_id)
      if activity
        activity.activity_order_position = :last
        activity.save!
      end
    end

    redirect_to({action: :index}, notice: "Activity order has been updated")
  end


  member_action :associated_ingredients, method: :get do
    @activity = Activity.find(params[:id])
  end

  member_action :update_associated_ingredients, method: :put do
    @activity = Activity.find(params[:id])
    @activity.update_attributes(steps_attributes:params[:activity][:steps_attributes])
    params[:step_ingredients].each do |id, ingredients|
      Step.find(id).update_ingredients(ingredients)
    end
    redirect_to({action: :show}, notice: "Step's ingredients updated")
  end

  member_action :versions, method: :get do
    @activity = Activity.find(params[:id])
    last_rev_num = @activity.last_revision().revision
    @versions = last_rev_num.downto(1).map do |r|
      rev = @activity.revision(r)
      ["##{r} - #{rev.created_at.localtime.strftime('%a %b %d, %Y %l:%M:%S %p %Z')}", r]
    end
  end

  member_action :restore_version, method: :get do
    @activity = Activity.find(params[:id])
    @version = params[:version]
    @activity.restore_revision!(@version)
    redirect_to({action: :show}, notice: "Version #{@version} has been restored and is the new version #{@activity.last_revision().revision}")
  end

  member_action :get_diff, method: :get do
    left = Activity.find(params[:id]).restore_revision(params[:version_left]).deep_json
    right = Activity.find(params[:id]).restore_revision(params[:version_right]).deep_json
    diff = json_differences(left, right)

    render text: JSON.pretty_generate(diff)
  end
end

