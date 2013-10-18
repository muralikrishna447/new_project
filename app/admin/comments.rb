ActiveAdmin.register Comment do
  menu parent: 'Engagement'

  index do
    column :id
    column :user
    column :commentable do |comment|
      link_to comment.commentable.title, send("#{comment.commentable.class.to_s.underscore}_path", comment.commentable.id)
    end
    column :content
    column :created_at do |comment|
      "#{time_ago_in_words(comment.created_at)} ago"
    end
    column :action do |comment|
      link_to 'edit', edit_admin_comment_path(comment)
    end
  end
end