class HomeController < ApplicationController

  def new_home
  end

  def manager
  end

  instrument_action :index, :about

  def index
    Librato.increment 'home.index'
    @show_app_add = true
    @classes = Assembly.pubbed_courses.order('created_at desc').limit(3).to_a
    prereg_assembly_classes = Assembly.prereg_courses.order('created_at desc').limit(1)
    pubbed_assembly_classes = Assembly.pubbed_courses.order('created_at desc').limit(1)
    @assembly_classes = prereg_assembly_classes | pubbed_assembly_classes
    @projects = Assembly.projects.published.order('created_at desc')
    @hero_cms = Setting.get_hero_cms()
    @latest = Activity.published.chefsteps_generated.include_in_feeds.order('published_at desc').first(6)

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
      {
        name: "Ryan Matthew Smith",
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/RGKBOD8BTAmF1eO3FHkE/convert?fit=crop&w=400&h=400&cache=true',
        bio: "<span class='text-center' style='display: block;'>Co-Founder (Alumnus)</span>Ryan was the principal photographer and photo editor for <i>Modernist Cuisine: The Art and Science of Cooking</i>. Smith's work has been featured by <i>Photographer</i>, <i>Life</i>, <i>Time</i>, <i>The New York Times</i>, Feature Shoot, Quo, and Abduzeedo."
      },
      {
        name: 'Michael Natkin',
        title: 'CTO',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/QcbYsv41Toea8zfUkLun/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Michael helped bring dinosaurs and Terminators to the big screen at Industrial Light and Magic, and he spent 13 years as a senior software engineer on Adobe After Effects. His cookbook, Herbivoracious, was a finalist for a 2013 James Beard Foundation award."
      },
      {
        name: 'Huy Nguyen',
        title: 'Developer',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/1pmrhQDVT9uTjBIKN6na/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Huy is a software developer who loves to build web experiences for people who love food. He studied mechanical engineering and worked for 9 years in the aerospace industry, learning to code in his free time before quitting his job to become a full-time software developer. Huy enjoys being an unofficial taste-tester for the ChefSteps kitchen, and he sees many important similarities between software development and recipe development."
      },
      {
        name: 'Nicholas Gavin',
        title: 'Development Chef',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/fr5GtDkNQfuEr9ju3vVZ/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Nick got his first restaurant job at age 17, washing dishes in Walla Walla, WA, and he quickly fell in love with the intensity and structure of the kitchen. After attending culinary school in Oregon, Nick took on a portfolio of challenges, cooking at Seattle fine dining staple Rover's, and later at The Cooking Lab's private events. He also worked on the development team for three months at the famed two-Michelin-starred restaurant Mugaritz, in Spain."
      },
      {
        name: 'A.L. Esterling',
        title: 'Director of Social Media',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/rLXAD1pHSpKB8ShcV6jo/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Lorraine's multi-faceted background includes a mid-70s conceptual art school education, a decade of restaurant work, and a twenty-year real-life Mad Men stint in advertising. She now works as ChefSteps' own social media guru. Other skills include expert toddler wrangling, nerdy cookbook perusal, and the ability to both create and spot typos instantly."
      },
      {
        name: 'Tim Salazar',
        title: 'Product Designer',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/pNwZ7VmQVGcdFAz8NSLg/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Tim has done design work for a huge bank, a huge telecommunications company, and a huge e-tailer. Of course, the natural progression was to go to a small startup and help build a design team. He grew up eating adobo and chili dogs."
      },
      {
        name: 'Benjamin Johnson',
        title: 'Development Chef',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/TRmjlTfYTBeHT6MjCs2t/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Ben graduated from Washington State University with a degree in Mechanical Engineering, but much of his learning took place in the kitchen of an on-campus sorority house, where he worked to help pay the bills. After school, he cooked at a fine dining restaurant in Walla Walla, WA, and spent a summer fishing in Alaska. Two years later, he was working as a sous chef at Spur Gastropub in Seattle when we found him and claimed him as our own."
      },
      {
        name: 'Hans Twite',
        title: 'Director of Audio',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/A3Crl8glRyqbQjgu54mM/convert?fit=crop&w=400&h=400&cache=true',
        bio: "Hans is a multi-instrumentalist, composer, and music producer. He does soundtrack design and audio production for every single ChefSteps video, and performs in local Seattle groups by night. Hans also happens to be a badass bartender, which we take full advantage of here at ChefSteps."
      },
      {
        name: 'Karen Quinn',
        title: 'Writer/Editor',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/ivvAekO6QGGNo02FR9cA/convert?fit=max&w=400&h=400&cache=true',
        bio: "Like any self-respecting English major, Karen began her career waiting tables. But not just any tables. Tables clothed in white linen, situated in fancy dining rooms, and attended by servers in tailored suits. She paid her way through unpaid editorial internships by learning everything she could about food, wine, and hospitality, finally landing at ChefSteps, where she puts both her love of words and her passion for food to work."
      },
      {
        name: 'Jess Voelker',
        title: 'Writer',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/68eXkVFVT32chsCtMWlA/convert?fit=max&w=300&h=300&cache=true',
        bio: "It's possible Jessica Voelker overstated her culinary knowledge when she landed her first food and drink writing job at <i>Seattle Met</i> magazine, but she soon became obsessed-particularly with the cocktail world, which she covered in-depth on the magazine's <i>Sauced</i> blog. Before coming to ChefSteps, she worked as a restaurant reviewer and editor at <i>Washingtonian</i> magazine in Washington, DC, a finalist for the James Beard Award for food writing in a general-interest magazine in both 2013 and 2014."
      },
      {
        name: 'Richard Wallace',
        title: 'Art Director',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/OD6BKPU7SO2NUA9kCcZw/convert?fit=max&w=300&h=300&cache=true',
        bio: "Sir Richard Wallace. Illegitimate son of the 4th Marquess of Hertford. Collector of fine European art. Friend to the besieged residence of Paris facing a Prussian invasion. That Richard Wallace does not work here. Our Richard Wallace is the one born in Louisiana, who's been working as a designer and motion graphics artist in Seattle area technology and creative agencies for a dozen years or so. Catch a glimpse of him through our windows at his standing desk, battling his desire to eat lunch early as he stares at beautiful footage of beautiful food all day long."
      },
      {
        name: 'Riley Moffit',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/8mg2DHfSTsmVLQlQeXBV/convert?fit=max&w=300&h=300&cache=true',
        bio: "Riley decided he wanted to become a professional cook when he was just ten years old, and he's been pursuing that dream ever since. He attended the French Culinary Institute in Manhattan, and went on to work in several award-winning kitchens such as Blue Hill at Stone Barns, Mistral Kitchen, and the Willows Inn. Riley is also an occasional musician and actor (featured prominently in many-a-ChefSteps video), and the man washes dishes like a boss."
      },
      {
        name: 'Emmett Barton',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/xkLpAiKZTHKQYuEg2OnV/convert?fit=max&w=300&h=300&cache=true',
        bio: "Born in Tennessee and raised by house pets, Emmett has lived in Japan, driven a motorcycle across Laos, been late for dinner in Bangkok, frozen on top of Mt. Fuji, and been a country bumpkin in New York. After doing his time in the advertising industry, he decided he wanted to work on things people actually care about. Now he attempts to apply half-remembered lessons from his English degree to design, occasionally with success."
      },
      {
        name: 'Alex Thomson',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/9PJlHJA4TsyOlFpFw2Wk/convert?fit=crop&w=300&h=300&cache=true',
        bio: 'Coming soon. ...Right, Alex?'
      },
      {
        name: 'Douglas Baldwin',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/3Dsl13bSESwQhrb5qEwg/convert?fit=max&w=300&h=300&cache=true',
        bio: "Douglas knows a thing or two about sous vide cooking: He posted his popular web guide in 2008, which has been translated into French, German, Portuguese, and Finnish; his book, <i>Sous Vide for the Home Cook</i>, was the third English-language cookbook (after Roca's and Keller's) on sous vide cooking when it came out in 2010; he wrote an article on it for the inaugural issue of the <i>International Journal of Gastronomy and Food Science</i>. If that wasn't enough, Douglas also has a Ph.D. in applied mathematics-his work on nonlinear dispersive wave interactions was highlighted in <i>Physics Today</i> and published in top journals like <i>Physical Review E</i>. Now he's using his knowledge of math, science, and cooking to help you cook smarter."
      },
      {
        name: 'Reva Keller',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/DHQfrHVSbaUJpK8e34uM/convert?fit=max&w=300&h=300&cache=true',
        bio: "Reva received a degree in fine arts from Cornish College of the Arts and has applied her expertise to everything from product photography to costume design. To avoid becoming a full-time starving artist, Reva decided to work somewhere where food was never scarce. At ChefSteps, she's fulfilling her childhood ambition of being around delicious food all day long, and making things look beautiful on film. Reva's greatest passions include stinky cheese, oysters, and Asian cuisine."
      },
      {
        name: 'Camp',
        title: 'Dog',
        image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/T4Yh0hBQTHKwKNSXxehj/convert?fit=max&w=400&h=400&cache=true',
        bio: 'More obsessed with food than the rest of us.'
      }
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
    end
    index
    render("home/index")
    # redirect_to root_path
  end

  def kiosk
    @hide_nav = true
  end

  def embeddable_signup
    @hide_nav = true
    render
  end

  def jsapi
  end
end
