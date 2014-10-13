class HomeController < ApplicationController

  def index
    @show_app_add = true
    @classes = Assembly.pubbed_courses.order('created_at desc').limit(3).to_a
    prereg_assembly_classes = Assembly.prereg_courses.order('created_at desc').limit(1)
    pubbed_assembly_classes = Assembly.pubbed_courses.order('created_at desc').limit(1)
    @assembly_classes = prereg_assembly_classes | pubbed_assembly_classes
    @projects = Assembly.projects.published.order('created_at desc')

    if current_user
      @latest = Activity.published.chefsteps_generated.include_in_feeds.order('published_at desc').first(6)
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
      { name: 'Tim Salazar', title: 'Product Designer', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/pNwZ7VmQVGcdFAz8NSLg/convert?fit=crop&w=400&h=400&cache=true', bio: "Tim has done design work for a huge bank, a huge telecommunications company, and a huge e-tailer. Of course, the natural progression was to go to a small startup and help build a design team. He grew up eating adobo and chili dogs." },
      { name: 'Benjamin Johnson', title: 'Development Chef', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/TRmjlTfYTBeHT6MjCs2t/convert?fit=crop&w=400&h=400&cache=true', bio: "Ben graduated from Washington State University with a degree in Mechanical Engineering. Throughout his college career, Ben cooked for a sorority house to help pay the bills. After school, he cooked at a fine dining restaurant  in Walla Walla, WA, and spent a summer fishing in Alaska. Two years later, he was working as Sous Chef at Spur Gastropub in Seattle, when we found him and claimed him as our own." },
      { name: 'Hans Twite', title: 'Director of Audio', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/A3Crl8glRyqbQjgu54mM/convert?fit=crop&w=400&h=400&cache=true', bio: "Hans is a multi instrumentalist, composer, and producer. Primarily working in soundtrack design and production consulting, he also continues to create and perform in local Seattle groups. Hans also happens to be an experienced bartender, which we take full advantage of here at ChefSteps." },
      { name: 'Kristina Krug', title: 'Multimedia Project Manager', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/qWzHicwzQaqGAnPSthgW/convert?fit=crop&w=400&h=400&cache=true', bio: "Kristina is a multi-talented multimedia expert. A native Oklahoman, Kristina graduated from UW with a degree in communications, and has since tackled a variety of projects for large corporations, art museums, start-up companies, and more. When she's not filming food, she creates legacy films for the elderly, and often corrals the ChefSteps team as its unofficial HR Lady." },
      { name: 'Karen Quinn', title: 'Writer/Editor', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/ivvAekO6QGGNo02FR9cA/convert?fit=max&w=400&h=400&cache=true', bio: "Like any self-respecting English major, Karen began her career waiting tables. But not just any tables. Tables clothed in clean white linen, situated in fancy dining rooms, and attended by servers in tailored suits. She paid her way through unpaid editorial internships by learning everything she could about food, wine, and hospitality, finally landing in a (paying) job that puts both her love of words and her unexpectedly developed passion for hospitality to work." },
      { name: 'Jess Voelker', title: 'Writer', image: 'http://placehold.it/400x400/&text=O_O', bio: "It's possible Jessica Voelker overstated her culinary knowledge when she landed her first food and drink writing job at Seattle Met magazine, but she soon became obsessed-particularly with the cocktail world, which she covered in-depth on the magazine's Sauced blog. Before coming to ChefSteps, she worked as a restaurant reviewer and editor at Washingtonian magazine in Washington, DC, a finalist for the James Beard Award for food writing in a general-interest magazine in both 2013 and 2014."},
      { name: 'Richard Wallace', title: 'Art Director', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/OD6BKPU7SO2NUA9kCcZw/convert?fit=max&w=300&h=300&cache=true', bio: "Sir Richard Wallace. Illegitimate son of the 4th Marquess of Hertford. Collector of fine European art. Friend to the besieged residence of Paris facing a Prussian invasion. That Richard Wallace does not work here. Our Richard Wallace is the one born in Louisiana, who's been working as a designer and motion graphics artist in Seattle area technology and creative agencies for a dozen years or so. Catch a glimpse of him through our windows at his standing desk, battling his desire to eat lunch early as he stares at beautiful footage of beautiful food all day long."},
      { name: 'Riley Moffit', image: 'http://placehold.it/400x400/&text=O_O', bio: "I've wanted to cook since I was around 10 years old. A few months after high school I moved to Manhattan to attend the French Culinary Institute. Then later I interned at Blue Hill at Stone Barns before moving back to seattle to work with William Belickis at Mistral Kitchen (the same chef Chris got his first job with, and where Grant was chef de cuisine for a number of years). After Mistral I worked at The Willows Inn for a season, then finally ended up at Chef Steps. I am inspired by talented people. I love being apart of cooking amazing food. I make music, and I'm really good at washing dishes."},
      { name: 'Emmett Barton', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/xkLpAiKZTHKQYuEg2OnV/convert?fit=max&w=300&h=300&cache=true', bio: "Born in Tennessee and raised by house pets, Emmett has lived in Japan, driven a motorcycle across Laos, been late for dinner in Bangkok, frozen on top of Mt. Fuji, and been a country bumpkin in New York. After doing his time in the advertising industry, he decided he wanted to work on things people actually care about. Now he attempts to apply half-remembered lessons from his English degree to design, occasionally with success."},
      { name: 'Alex Thomson', image: 'http://placehold.it/400x400/&text=O_O', bio: 'Coming soon'},
      { name: 'Douglas Baldwin', image: 'http://placehold.it/400x400/&text=O_O', bio: "Douglas knows a thing or two about sous vide cooking: he posted his popular web guide in 2008, which has been translated into French, German, Portuguese, and Finish; his book, Sous Vide for the Home Cook, was the third English-language cookbook (after Roca's and Keller's) on sous vide cooking when it came out in 2010; he helped the New South Wales Food Authority on their sous-vide food-safety guidelines for restaurants; he's given webinars on it for the American Chemical Society; was interviewed in Cooking for Geeks; and even wrote a review article on it for the inaugural issue of the International Journal of Gastronomy and Food Science. If that wasn't enough, Douglas also has a Ph.D. in applied mathematics from the University of Colorado Boulder; his work on nonlinear dispersive wave interactions was highlighted in Physics Today and SIAM News and published in top journals like Physical Review E. Now he's using his knowledge of math, science, and cooking to help you cook smarter."},
      { name: 'Camp', title: 'Dog', image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/T4Yh0hBQTHKwKNSXxehj/convert?fit=max&w=400&h=400&cache=true', bio: 'More obsessed with food than the rest of us.' }
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

  def kiosk
    @hide_nav = true
  end

  def jsapi
  end
end
