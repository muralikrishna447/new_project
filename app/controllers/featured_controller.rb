class FeaturedController < ApplicationController
  def index
    recipes = Activity.published.chefsteps_generated.include_in_feeds.order('published_at desc').first(3)
    recipes_hash = recipes.map{|r| {title: r.title, description: r.description, image: filepicker_cropped_image(r.featured_image,230,130), url: activity_url(r)}}
    classes = Assembly.pubbed_courses.order('created_at desc').limit(3).to_a
    classes_hash = classes.map{|c| {title: c.title, description: c.description, image: filepicker_cropped_image(c.image_id,230,130), url: landing_class_path(c)}}
    render json: {recipes: recipes_hash, classes: classes_hash}.to_json
  end

  def cover
    recipe = Activity.published.chefsteps_generated.include_in_feeds.order('published_at desc').first
    @image_url = filepicker_arbitrary_image(recipe.featured_image, 1600)
    render inline: "<%= image_tag @image_url %>", layout: "barebones"
  end
end