class HomeController < ApplicationController

  def index
    @classes = Assembly.pubbed_courses.order('updated_at desc').to_a
    prereg_assembly_classes = Assembly.prereg_courses.order('updated_at desc').limit(1)
    pubbed_assembly_classes = Assembly.pubbed_courses.order('updated_at desc').limit(1)
    @assembly_classes = prereg_assembly_classes | pubbed_assembly_classes

    if current_user
      @latest = Activity.published.chefsteps_generated.include_in_feeds.order('published_at desc').first(6)
      @recipe_developments = Assembly.published.recipe_developments.last(3)
      # @followings_stream = Kaminari::paginate_array(current_user.followings_stream).page(params[:page]).per(6)
      # @stream = current_user.received_stream.take(4)
    else
      @heroes = Setting.featured_activities
      @recipes = Activity.published.chefsteps_generated.recipes.include_in_feeds.includes(:steps).last(6) - @heroes
      @techniques = Activity.published.chefsteps_generated.techniques.include_in_feeds.includes(:steps).last(6) - @heroes
      @sciences = Activity.published.chefsteps_generated.sciences.include_in_feeds.includes(:steps).last(6) - @heroes
      @returning_visitor = cookies[:returning_visitor]
      @new_visitor = params[:new_visitor] || !@returning_visitor
      @user = User.new
    end
  end

  def about
    # @chris = Copy.find_by_location('creator-chris')
    # @grant = Copy.find_by_location('creator-grant')
    # @ryan = Copy.find_by_location('creator-ryan')
    # t = %w[hans@chefsteps.com ben@chefsteps.com lorraine@chefsteps.com kristina@chefsteps.com tim.salazar@gmail.com hueezer@gmail.com michaelnatkin@gmail.com edward@chefsteps.com nick@chefsteps.com]
    # @team = User.where(email: t)
    # f = %w[chris@chefsteps.com desunaito@gmail.com grant@chefsteps.com]
    # @founders = User.where(email: f)

    @team = [
      { name: 'Edward Starbird', title: 'CFO', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/5Iq86WtrSAe9xC0HCMre/convert?fit=crop&w=400&h=400&cache=true', bio: "Edward spent 8 years in operations as an engineer, a production manager, and a supply chain manager. Seeking a smaller company, he has completely changed gears at ChefSteps and now wears many hats that keep the doors open, the lights on, and the development team innovating." },
      { name: 'Michael Natkin', title: 'CTO', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/QcbYsv41Toea8zfUkLun/convert?fit=crop&w=400&h=400&cache=true', bio: "Michael helped bring dinosaurs and Terminators to the big screen at Industrial Light and Magic, and he spent 13 years as a senior software engineer on Adobe After Effects. His cookbook, Herbivoracious, was a finalist for a 2013 James Beard Foundation award." },
      { name: 'Huy Nguyen', title: 'Developer', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/1pmrhQDVT9uTjBIKN6na/convert?fit=crop&w=400&h=400&cache=true', bio: "Huy is a software developer who loves to build web experiences for people who love food. He studied mechanical engineering and worked for 9 years in the aerospace industry, learning to code in his free time before quitting his job to become a full-time software developer. Huy enjoys being an unofficial taste-tester for the ChefSteps kitchen, and he sees many important similarities between software development and recipe development." },
      { name: 'Nicholas Gavin', title: 'Development Chef', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/fr5GtDkNQfuEr9ju3vVZ/convert?fit=crop&w=400&h=400&cache=true', bio: "Nick got his first restaurant job at age 17, washing dishes in Walla Walla, WA. He quickly fell in love with the intensity and structure of the kitchen. After attending culinary school in Oregon, Nick took on a portfolio of challenges, cooking at Seattle fine dining staple Rover's, and later at Modernist Cuisine private events. He also worked on the development team for three months at the famed two-Michelin-starred restaurant Mugaritz, in Spain." },
      { name: 'A.L. Esterling', title: 'Director of Social Media', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/rLXAD1pHSpKB8ShcV6jo/convert?fit=crop&w=400&h=400&cache=true', bio: "Lorraine's multi-faceted background includes a mid-70s conceptual art school education, a decade of restaurant work, and a twenty-year real-life Mad Men stint in advertising. She now works as ChefSteps' own social media guru. Other skills include expert toddler wrangling, nerdy cookbook perusal, and the ability to both create and spot typos instantly." },
      { name: 'Tim Salazar', title: 'Product Designer', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/pNwZ7VmQVGcdFAz8NSLg/convert?fit=crop&w=400&h=400&cache=true', bio: "Tim has done design work for a huge bank, a huge telecommunications company, and a huge e-tailer. Of course, the natural progression was to go to a small startup with only one designer. He grew up eating adobo and chili dogs." },
      { name: 'Benjamin Johnson', title: 'Development Chef', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/TRmjlTfYTBeHT6MjCs2t/convert?fit=crop&w=400&h=400&cache=true', bio: "Ben graduated from Washington State University with a degree in Mechanical Engineering. Throughout his college career, Ben cooked for a sorority house to help pay the bills. After school, he cooked at a fine dining restaurant  in Walla Walla, WA, and spent a summer fishing in Alaska. Two years later, he was working as Sous Chef at Spur Gastropub in Seattle, when we found him and claimed him as our own." },
      { name: 'Hans Twite', title: 'Director of Audio', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/A3Crl8glRyqbQjgu54mM/convert?fit=crop&w=400&h=400&cache=true', bio: "Hans is a multi instrumentalist, composer, and producer. Primarily working in soundtrack design and production consulting, he also continues to create and perform in local Seattle groups. Hans also happens to be an experienced bartender, which we take full advantage of here at ChefSteps." },
      { name: 'Kristina Krug', title: 'Multimedia Project Manager', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/qWzHicwzQaqGAnPSthgW/convert?fit=crop&w=400&h=400&cache=true', bio: "Kristina is a multi-talented multimedia expert. A native Oklahoman, Kristina graduated from UW with a degree in communications, and has since tackled a variety of projects for large corporations, art museums, start-up companies, and more. When she's not filming food, she creates legacy films for the elderly, and often corrals the ChefSteps team as its unofficial HR Lady." },
      { name: 'Karen Quinn', title: 'Managing Editor', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/ivvAekO6QGGNo02FR9cA/convert?fit=max&w=400&h=400&cache=true', bio: "Karen grew up in New England among family, friends, and teachers who instilled in her a deep appreciation for the power of words. She received a Bachelor's degree in English literature from Colgate University and worked on the editorial staff at Seattle Metropolitan magazine before coming to ChefSteps. A long&#8212;time habitu&#233; of kitchens&#8212;her own and some of the finest in Seattle&#8212;Karen has over the years developed a love of food, wine, and hospitality to match her fascination with words. She brings to ChefSteps her enthusiasm for both." },
      { name: 'Cloud', title: 'Dog', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/7X5Dnuk3TmTqvqWmkHQA/convert?fit=max&w=400&h=400&cache=true', bio: 'More obsessed with food than the rest of us.' }
    ]

    @about_left = Copy.find_by_location('about-left')
    @about_right = Copy.find_by_location('about-right')
    @about_story = Copy.find_by_location('about-story')
    @about_kitchen = Copy.find_by_location('about-kitchen')

    @about_tips = [
      { image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/enLJ0PSqRpPdsI5k2Apg/convert?fit=crop&w=100&h=100&cache=true', copy: Copy.find_by_location('about-tip-weight') },
      { image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/n30SnaXGQGWt0KcW1bfz/convert?fit=crop&w=100&h=100&cache=true', copy: Copy.find_by_location('about-tip-ingredients') },
      { image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/CofctCnTwWvm7A2b8ShV/convert?fit=crop&w=100&h=100&cache=true', copy: Copy.find_by_location('about-tip-heat') },
      { image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/lR9PT51iSuKJjmluszsa/convert?fit=crop&w=100&h=100&cache=true', copy: Copy.find_by_location('about-tip-community') },
      { image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/weHQHUSTBqKRI1bk2bMw/convert?fit=crop&w=100&h=100&cache=true', copy: Copy.find_by_location('about-tip-equipment') },
      { image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/a7vIXo8R4WeuesRE2J41/convert?fit=crop&w=100&h=100&cache=true', copy: Copy.find_by_location('about-tip-tools') }
    ]

    @classes = Assembly.pubbed_courses
    @recipes = Activity.published.recipes.chefsteps_generated.last(6)
  end

  def welcome
    if params[:referrer_id] && params[:referred_from] && mixpanel_anonymous_id.present?
      referrer = User.find(params[:referrer_id])
      session[:referrer_id] = referrer.id
      session[:referred_from] = params[:referred_from]
      set_referrer_in_mixpanel("#{session[:referred_from]} invitee visited")
      mixpanel.people.set(mixpanel_anonymous_id, {invited_from: params[:referred_from], invited_by: referrer.email, invited_by_id: referrer.id})
    end
    index
    render("home/index")
    # redirect_to root_path
  end
end
