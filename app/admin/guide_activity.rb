class ::ActiveAdmin::Views::IndexAsGuideActivity < ActiveAdmin::Views::IndexAsTable
  def build(page_presenter, collection)
    h2 "Instructions"
    ol
      li "If you have a new guide and have created a hand-crafted activity for it before the guide has published, choose New Guide Activities and set it up in advance."
      li "If a guide has an automatically created activity and you want to manually edit the activity, click Edit below and turn off auto-update so your changes won't be lost."
      li "If you have a hand-crafted activity and an automatically created activity has also been made, delete the Guide Activity below and follow the steps for the first bullet above, then unpublish the automatically created activity. Or ask Michael for help."
    br
    super
  end
end

ActiveAdmin.register GuideActivity, as: 'Guide Activities' do
  config.sort_order = ''
  config.batch_actions = false

  menu priority: 2

  index title: 'Guide Activities', as: :guide_activity do
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

