namespace :comments do
  task :set_include_to_true => :environment do
    inclusions = AssemblyInclusion.all
    inclusions.each do |inclusion|
      inclusion.include_disqus = true
      inclusion.save
      puts "Updated Inclusion:"
      puts inclusion.inspect
      puts "-"*20
    end
  end
end

# namespace :comments do
#   require 'nokogiri'
#   require 'json'
#   @already_migrated = [1010501239,1011380285,1018262599,1018468742,1018585235,1018667581,1019638717,1019828451,1066290857,1068262685,1295525620,1264997536,962229102,999911268,999962273,1000026734,1124938198,1124988380,829189399,829202900,829313934,829222726,829222921,829248033,830047497,830435276,944401765,1268891248,955995598,956022987,943531807,1101430664,947534754,1100959139,951469050,951986409,967450934,967891262,974675384,974830073,1012667374,1014094663,1016594048,1017249226,1019116234,1019832491,1207263044,1101402486,1101430401,984989326,985254503,841392515,729468828,729809503,765349799,779470436,820297298,820463314,726288542,726861831,726444956,759516916,759693794,759766277,759784213,715489632,717680298,723676034,726863235,731055333,731120608,1281144168,1283546488,1239559004,1239784310,1254414053,763989148,764293522,766312697,766796335,769361059,769434856,878743655,881723544,1013977689,1014096801,1014117137,1014126533,936021218,936196649,1243644284,1245161770,766631876,779684788,819526006,819659968,822569175,822596928,920929319,922428758,1010546816,1011378551,1058745833,981286764,900007463,1282036554,995323643,790880520,791086470,791467024,792011281,815270004,815698015,816408563,792118238,792332162,793993118,815087573,803221974,805173604,810491538,811070381,811859100,812089513,816409208,817160754,817926111,818346237,836460725,836773778,838718936,840973833,930898423,931177389,1059352090,1247653340,1247667023,957895717,957900059,1239128769,987016596,988709822,988401014,988711036,988487479,989188316,989352490,989614994,1166599926,1167131048,1167369741,1252160209,1252488141,1271178686,805956424,808973944,809794357,817858365,817905600,852378336,946148805,1014132533,1081602608,1084701928,1085419662,1277257249,995320134,970985165,978053551,978341826,979303205,979713733,979713415,1064762344,893108201,893761126,896093934,1177183389,1177489403,988130080,1160312784,1306719937,1306781967,1306849799,1306893128,1310771042,1311415677,1311573669,1312273494,1312621814,1184438655,1184652845,995322299,1035440622,725647345,726412289,732938177,733381486,744476495,744978136,745439709,733265642,733380285,733339737,733379360,734115760,734900423,735170249,736870232,769151281,769237327,753621457,753808090,769454876,769641253,770540134,770638190,756509671,756974705,820004920,820291948,846066094,825777917,825998014,759216120,759306504,765563171,765589192,769441405,769442649,769461845,769640840,769477916,769636391,826847328,769966694,770656587,770907021,771026136,771231575,771276276,801251129,801667255,802785041,802788608,817285095,817418570,824330107,824339477,824366008,824641627,852443140,853158382,864551405,865356081,876784807,878251097,896505400,896735765,906319180,911459982,1068061624,1068262213,1127463306,1127509205,1147655516,1159362150,1159518341,1160359369,1160369410,1220455845,1287499614,944223035,944284444,944227607,952913094,953864716,1038638751,1153225109,995323952,1154167892,1078497563,1114187536,1114049155,1033973742,1036664312,1039172058,900583853,1033220326,1033611953,1036887843,1037229768,1049363636,1050125519,1050721178,1053499179,1061621619,1061844426,1062455103,1062446703,1062521639,1064755745,1233673117,1062864229,1064754611,1065091428,1073291598,1114688971,758301370,781446909,781545767,781562014,838789401,900586787,900610574,900632214,900890711,1097906393,1106375821,1107928205,1123507739,1123510471,1125110815,1126129899,1193544282,1240520619,1240775585,1242143812,852522105,853157626,854637834,854675448,888647549,888968204,1073437510,995321619,1024921611,976251564,978052661,1058354179,1058442218,1058601492,1058768035,1058848010,1058932215,1059331291,1060390098,1060474242,1060992769,1061460992,1061703548,1061286071,1061462785,1061799068,1067712903,1067714751,1068011690,1073293397,1083900011,1195009317,1310576986,1311395214,1136597093,1138561719,1137435848,1138562806,1139739655,1142061037,1171104755,1171788500,1171794605,1208319490,1234854093,1234905958,1235099318,1273336869,873092167,873379493,874120859,874489254,873134096,873476381,874489700,883064557,908428955,911450528,1116475279,1117087527,1120339898,1155292448,1117413140,1173467700,943320456,943341329,943351790,943369483,943383028,1047434476,1048104740,1048247565,1052851513,1053500771,1144529741,1295182441,943205497,952833719,953865538,953891930,1192668199,849519973,1303669766,945492967,1058496600,1154355745,1156201037,1193341621,951211005,951987030,944396644,944533526,958539071,959024255,964372455,964797025,1075687031,993489669,993698546,1208076655,1209657588,1293276070,959133359,959165890,959316329,960009168,967618736,962296562,963123930,972469553,1201433518,1201434920,810125435,810367977,838796528,873154700,972961505,1054705284,1109321494,1194288002,1194007513,1194265789,1199589849,1213725947,1031002233,1031520785,1062894271,1064754351,1063097244,1064753253,1065373886,1226478470,1266252027,834175203,834266923,837159625,839109055,922240172,922415466,951412622,951987514,993696932,1178057558,1153052397,949629739,950882365,950821463,1007226469,1016443880,1017245764,1018359358,952705969,953204370,974262011,975654154,1172071348,1172156208,1172211400,1172447573,1197982589,1220331552,1138979797,1139861044,1139838859,1139917508,1140367947,950100339,956074833,956789973,959180158,959226560,961836106,1006322164,1054146533,1055902984,1057206214,1213115011,1310137029,1204611270,1205640759,1222785869,1220428843,1220499662,1220520162,1220689258,1220870189,1220925746,1220553546,1220935860,1222296298,1220685098,1222266797,1222504018,1224196996,1221238874,1222116503,1225496147,1225973809,1227045487,1252631195,1253717835,1238763523,866358148,867437894,869711883,871717977,875462472,876605031,870957469,871717770,887123945,887632138,1290109993,991589978,991957221,999796839,999896177,996604394,996886781,1001560225,1001600565,1002494189,1004062729,1002216414,1012929886,1014094159,1015567270,1015681851,1168817098,1169496464,1128989676,1129907135,1129598307,1129900826,1135127162,1136574861,1152736505,860667704,861449418,864942990,865348021,865405686,865518814,865563436,865413708,888150658,888298945,891347900,891378167,1091319679,1172143958,1172446408,1172918173,1200812837,1201016966,1272208710,1282068308]
#   @migrated_comments = []
#   task :migrate_activities => :environment do
#     connect_to_disqus_xml('~/Downloads/chefstepsproduction-2014-04-11T18-23-47.443925-all.xml')
#     connect_to_es
#     connect_to_disqus_api
#     #go through each activity and get disqus id
#     activities = Activity.published
    
#     activities.each do |activity|
#       migrate_one(activity)
#     end

#     # activity = Activity.find('honey-sriracha')
#     # activity = Activity.find('buffalo-style-chicken-skin')
#     # activity = Activity.find('strawberry-shortcake')
#     # migrate_one(activity)

#   end

#   task :migrate_polls => :environment do

#   end

#   task :migrate_ingredients => :environment do

#   end

#   def migrate_one(activity)
#     # Hash containing meta data to help with migration
#     c = []

#     disqus_thread_id = determine_disqus_thread_id("activity-#{activity.id}")

#     # get the comments
#     if disqus_thread_id
#       disqus_comments = get_disqus_posts(disqus_thread_id)
#       disqus_comments.each do |comment|
#         unless @already_migrated.include?(comment['@dsq:id'].to_i)
#           image = get_disqus_image(comment['@dsq:id'])
#           c_info = Hash.new
#           c_info[:commentable_type] = 'activity'
#           c_info[:commentable_id] = activity.id
#           c_info[:disqus_thread_id] = disqus_thread_id
#           c_info[:disqus_id] = comment['@dsq:id']
#           c_info[:disqus_parent_id] = comment['parent']['@dsq:id'] if comment['parent']
#           c_info[:disqus_user_email] = comment['author']['email']
          
#           c_info[:created_at] = (comment['createdAt']).to_i * 1000

#           c_info[:chefsteps_user_id] = get_chefsteps_user_id(comment['author']['email'])
#           content = compose_content(comment,image)
#           if c_info[:chefsteps_user_id]
#             c_info[:content] = content
#           else
#             c_info[:content] = content + " - originally posted by #{comment['author']['name']}"
#           end
#           c << c_info
#         end
#       end
#     end

#     # Loop through c_info and migrate the parents
#     c.each do |comment_info|
#       unless comment_info[:disqus_parent_id]
#         post_to_es(comment_info)
#         find_children(c, comment_info, 1)
#       end
#     end
#   end

#   def get_disqus_image(disqus_thread_id)
#     disqus_data = @disqus.get('/api/3.0/posts/details.json', {post: disqus_thread_id, api_key: 'Y1S1wGIzdc63qnZ5rhHfjqEABGA4ZTDncauWFFWWTUBqkmLjdxloTb7ilhGnZ7z1'})
#     media = JSON.parse(disqus_data.body)['response']['media']
#     unless media.blank?
#       image = media[0]['url']
#     end
#     image
#   end

#   def compose_content(comment,image)
#     content = Nokogiri::HTML(comment['message']).text
#     content = "<p>" + content + "</p>"
#     content = content + "<img src='#{image}'>" unless image.blank?
#     content
#   end

#   def post_to_es(comment_info)
#     puts '-----------------'
#     post_body = {
#       "upvotes" => [],
#       "asked" => [],
#       "createdAt" => comment_info[:created_at],
#       "author" => comment_info[:chefsteps_user_id],
#       "content" => comment_info[:content],
#       "dbParams" => {
#         "commentsId" => "#{comment_info[:commentable_type]}_#{comment_info[:commentable_id]}"
#       }
#     }
#     post_body["parentCommentId"] = comment_info[:bloom_parent_id] unless comment_info[:bloom_parent_id].blank?
#     puts post_body
#     post_response = @elasticsearch.post do |req|
#       req.url "/bloom/comment"
#       req.headers['Content-Type'] = 'application/json'
#       req.body = JSON.generate(post_body)
#     end
#     comment_info[:bloom_id] = JSON.parse(post_response.body)["_id"]
#     puts comment_info
#     puts '*** Posting to Elasticsearch ***'
#     @migrated_comments << comment_info[:disqus_id]
#     puts @migrated_comments.join(',')
#   end

#   def find_children(data, parent, depth)
#     children = data.select{|child| child[:disqus_parent_id] == parent[:disqus_id]}
#     if children.length > 0
#       children.each do |child|
#         child[:bloom_parent_id] = parent[:bloom_id]
#         post_to_es(child)
#         # puts '   '*depth + child[:content]

#         find_children(data, child, depth + 1)
#       end
#     end
#   end

#   def connect_to_disqus_xml(path_and_filename)
#     xml = File.read(File.expand_path(path_and_filename))
#     parser = Nori.new
#     @parsed = parser.parse(xml)['disqus']
#   end

#   def determine_disqus_thread_id(activity_id)
#     threads = @parsed['thread']
#     thread = threads.select{|k,v| k["id"] == activity_id}[0]
#     unless thread.blank?
#       thread['@dsq:id']
#     else
#       nil
#     end
#   end

#   def get_disqus_thread(thread_id)
#     threads = @parsed['thread']
#     thread = threads.select{|k,v| k['@dsq:id'] == thread_id}
#     thread
#   end

#   # Get disqus comments by thread id
#   def get_disqus_posts(thread_id)
#     posts = @parsed['post']
#     specific_posts = posts.select{|k,v| k['thread']['@dsq:id'] == thread_id}
#     specific_posts
#   end

#   def filter_comments_without_parent(comments)
#     comments_without_parents = []
#     comments_with_parents = []
#     comments.each do |comment|
#       if comment['parent'].blank?
#         comments_without_parents << comment
#       else
#         comments_with_parents << comment
#       end
#     end
#     puts '***** WITHOUT PARENTS ******'
#     puts comments_without_parents
#     puts '***** WITH PARENTS ******'
#     puts comments_with_parents
#   end

#   def connect_to_es
#     @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
#       faraday.request  :url_encoded             # form-encode POST params
#       faraday.response :logger                  # log requests to STDOUT
#       faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
#     end
#   end

#   def connect_to_bloom
#   end

#   # Functions to help pull data from chefsteps
#   def get_chefsteps_user_id(email)
#     user = User.where(email: email).first
#     user.id unless user.blank?
#   end

#   def connect_to_es
#     @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
#       faraday.request  :url_encoded             # form-encode POST params
#       faraday.response :logger                  # log requests to STDOUT
#       faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
#     end
#   end

#   def connect_to_disqus_api
#     @disqus = Faraday.new(:url => 'https://disqus.com') do |faraday|
#       faraday.request  :url_encoded             # form-encode POST params
#       faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
#     end
#   end

#   task :update_events_count => :environment do
#     User.reset_column_information
#     User.find_each do |user|
#       if User.reset_counters user.id, :events
#         user.reload
#         puts 'updated'
#         puts user.inspect
#         puts '*********'
#       end
#     end
#   end
# end