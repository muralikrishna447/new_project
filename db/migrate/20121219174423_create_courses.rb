class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.boolean :published, :default => false

      t.decimal :course_order

      t.timestamps
    end
  end
end
