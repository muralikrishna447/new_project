
namespace :pages do

  task :home => :environment do
    page = Page.find 'home'
    component_slugs = %w(home-one home-two home-three home-four home-five home-six home-seven home-eight)

    component_slugs.each_with_index do |slug, index|
      component = Component.find slug
      component.component_parent = page
      component.position = index
      if component.save
        puts "Saved component: #{component.slug}"
        puts "Component Parent: #{component.component_parent.slug}"
        puts component.inspect
      else
        puts "Error saving component: #{component.slug}"
      end
      puts '*'*30
    end
  end
end
