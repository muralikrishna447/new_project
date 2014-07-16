ActiveAdmin.register Setting, as: 'Site Settings' do
  menu priority: 3

  form do |f|
    f.inputs "Setting" do
      f.input :featured_activity_1_id, as: :select, collection: Activity.published.order('title ASC'), input_html: {class: 'featured-activity-select', style: 'width: 200px'}
      f.input :featured_activity_2_id, as: :select, collection: Activity.published.order('title ASC'), input_html: {class: 'featured-activity-select', style: 'width: 200px'}
      f.input :featured_activity_3_id, as: :select, collection: Activity.published.order('title ASC'), input_html: {class: 'featured-activity-select', style: 'width: 200px'}
      f.input :footer_image
      f.input :global_message_active
      f.input :global_message
      f.input :forum_maintenance
    end

    f.buttons
  end
end