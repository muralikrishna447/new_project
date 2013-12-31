class AddTestimonialToAssemblies < ActiveRecord::Migration
  def change
    add_column :assemblies, :testimonial_copy, :text
  end
end
