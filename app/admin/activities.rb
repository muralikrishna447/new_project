def version_popup_entry(rev_num, rev)
  user = rev.last_edited_by ? rev.last_edited_by.email : "unknown"
  ["##{rev_num} #{user[/[^@]+/]} #{rev.updated_at.localtime.strftime('%a %b %d, %Y %l:%M %p %Z')}", rev_num]
end


ActiveAdmin.register Activity do
  config.sort_order = 'activity_order_asc'
  before_action :load_activity, only: [:show, :edit, :update, :destroy]

  permit_params :title, :byline, :youtube_id, :vimeo_id, :yield, :timing, :promote_order, :is_promoted,
                :difficulty, :description, :short_description, :equipment, :ingredients,
                :nesting_level, :transcript, :featured_image_id, :image_id,
                :steps_attributes, :source_activity, :source_activity_id,
                :source_type, :author_notes, :currently_editing_user, :include_in_gallery,
                :creator, :premium, :studio, :summary_tweet, :published, :activity_type => [],
                :tag_list => [], :child_activity_ids => []

  filter :title
  filter :created_at
  filter :updated_at
  filter :published
  filter :published_at
  filter :description
  filter :creator, as: :check_boxes, collection: [0]

  menu priority: 2

  action_item :view, only: [:show, :edit] do
    link_to_publishable activity, 'View on Site'
  end

  show do |activity|
    render "show", activity: activity
  end

  form partial: 'form'

  action_item :view, only: [:show, :edit] do
    link_to('Edit Step Ingredients', associated_ingredients_admin_activity_path(activity))
  end

  action_item :view, only: [:show, :edit] do
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
    column :is_promoted do |activity|
      activity.promoted
    end
    column :published_at
    actions
  end

  controller do
    def create
      equipment_attrs = separate_equipment
      step_attrs = separate_steps
      ingredient_attrs = separate_ingredients
      @activity = Activity.create(actitity_params)
      @activity.update_equipment(equipment_attrs)
      @activity.update_steps(step_attrs)
      @activity.update_ingredients(ingredient_attrs)
      @activity.last_edited_by = current_user
      create!
    end

    def update
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

    def load_activity
      @activity = Activity.friendly.find(params[:id])
    end

    def actitity_params
      params.require(:activity).permit( :title, :byline, :youtube_id, :vimeo_id, :yield, :timing, :promote_order, :is_promoted,
                                       :difficulty, :description, :short_description, :equipment, :ingredients,
                                       :nesting_level, :transcript, :featured_image_id, :image_id,
                                       :steps_attributes, :child_activity_ids, :source_activity, :source_activity_id,
                                       :source_type, :author_notes, :currently_editing_user, :include_in_gallery,
                                       :creator, :premium, :studio, :summary_tweet, :published, :activity_type => [], :tag_list => [])
    end
  end

  member_action :associated_ingredients, method: :get do
    @activity = Activity.friendly.find(params[:id])
  end

  member_action :update_associated_ingredients, method: :patch do
    @activity = Activity.friendly.find(params[:id])
    @activity.store_revision do
      @activity.update_attributes(steps_attributes:params[:activity][:steps_attributes])
      params[:step_ingredients].each do |id, ingredients|
        Step.find(id).update_ingredients(ingredients)
      end
      @activity.last_edited_by = current_user
      @activity.save!
    end
    redirect_to({action: :show}, notice: "Step's ingredients updated")
  end

  member_action :versions, method: :get do
    @activity = Activity.friendly.find(params[:id])
    @versions = []
    last_rev_num = 0
    if @activity.last_revision()
      last_rev_num = @activity.last_revision().revision
        @versions = last_rev_num.downto(1).map do |r|
          rev = @activity.restore_revision(r)
          version_popup_entry(r, rev)
        end
    end
    @versions.unshift(version_popup_entry(last_rev_num + 1, @activity))
  end

  member_action :restore_version, method: :get do
    @activity = Activity.friendly.find(params[:id])
    @version = params[:version]
    @activity.restore_revision!(@version)
    redirect_to({action: :show}, notice: "Version #{@version} has been restored and is the new version #{@activity.last_revision().revision + 1}")
  end
end

