ActiveAdmin.register GuideActivity, as: 'Guide Activities' do
  config.sort_order = ''
  config.batch_actions = false

  menu priority: 2

  index title: 'Guide Activities' do
    column :guide_title
    column "Guide ID", :guide_id
    column "Activity" do |ga|
      link_to(ga.activity.title, activity_path(ga.activity))
    end
    column :autoupdate
    default_actions
  end

  form do |f|
    f.inputs "Guide: #{f.object.guide_title} (#{f.object.guide_id})" do
      f.input :guide_id, label: "Guide ID" if f.object.guide_id.blank?
      f.input :activity, collection: Activity.chefsteps_generated.by_updated_at('desc')
      f.input :autoupdate, label: "Autoupdate when guide content changes"
    end

    f.buttons
  end
end

