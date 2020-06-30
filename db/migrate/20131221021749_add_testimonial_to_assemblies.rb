class AddTestimonialToAssemblies < ActiveRecord::Migration[5.2]
  def change
    add_column :assemblies, :testimonial_copy, :text
  end
end
