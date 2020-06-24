class CreateGuideActivities < ActiveRecord::Migration[5.2]
  def up
    create_table :guide_activities do |t|
      t.string :guide_id
      t.string :guide_title
      t.integer :activity_id
      t.string :guide_digest
      t.boolean :autoupdate, default: true
      t.timestamps
    end

    add_index :guide_activities, :guide_id
    add_index :guide_activities, :activity_id

    # List of guides that have handcrafted activities, curated by Rick
    existing = [
      {guide_id: '2xIIxBtjwAKSMiWIOAOC4i', guide_title: 'Amazing Overnight Bacon', activity_slug: 'tips-tricks-the-world-s-best-bacon-cooks-allllll-night-long'},
      {guide_id: '3dPM8aI11ewmuqyqimcUUi', guide_title: 'Basic Chicken Breast', activity_slug: 'sous-vide-chicken-breast'},
      {guide_id: '5h1VsPRjLyE0sA08q6sumc', guide_title: 'Basic Pork Chop', activity_slug: 'sous-vide-pork-chop'},
      {guide_id: '6cK0F7Oxs4gmQOmqIsEeYA', guide_title: 'Basic Salmon', activity_slug: 'sous-vide-salmon'},
      {guide_id: '2MH313EsysIOwGcMooSSkk', guide_title: 'Basic Steak', activity_slug: 'sous-vide-steak'},
      {guide_id: '6ypWSjcnQs2S2iWyyo2USW', guide_title: 'Beluga Lentils for Salads and Sides', activity_slug: 'no-fail-beluga-lentils'},
      {guide_id: '2w9g9mSAAE0aGgmGKwe84U', guide_title: 'Braised and Glazed Lamb Shank', activity_slug: 'braised-and-glazed-lamb-shank'},
      {guide_id: '5ka9e9SZvquW8IIKeu8mak', guide_title: 'Cantonese BBQ Pork (Char Siu', activity_slug: 'char-siu-tender-cantonese-style-barbecued-pork'},
      {guide_id: '1JUckRCQo8caWQISCqS4wO', guide_title: 'Country-Style Braised Spareribs', activity_slug: 'soul-soothing-braised-spareribs'},
      {guide_id: '3y3XhiDIDeOEGGcqCc6iQk', guide_title: 'Cracklin Creme Brulee', activity_slug: 'foolproof-cracklin-creme-brulee'},
      {guide_id: '1P7m0logvWo6IiK8sYmScy', guide_title: 'Creme Anglaise Three Ways', activity_slug: 'creme-anglaise'},
      {guide_id: '6BF5SJNX6ocue440sqmYos', guide_title: 'Crispy Duck Leg Confit', activity_slug: 'easy-crispy-duck-leg-confit'},
      {guide_id: '6OhnqWSJA464oEym6Y0CWc', guide_title: 'Crowd-Pleasing Pot de Creme', activity_slug: 'pot-de-creme'},
      {guide_id: '3FZVbbLD4sks2YGcsQyqea', guide_title: 'Cuban-Style Mojo Pork', activity_slug: 'tender-smoky-mojo-marinated-pork-shoulder'},
      {guide_id: '5fUWx8fYe4WqK6UGQw2eK4', guide_title: 'Dang Delicious Duck Eggs', activity_slug: 'dang-delicious-sous-vide-duck-eggs'},
      {guide_id: '16vjMNbLpcsy4C6gEg0KgS', guide_title: 'Decadent Cheesecake', activity_slug: 'the-quickest-simplest-way-to-make-bomb-cheesecake'},
      {guide_id: '7gR3nLNkIgImIOCKC4IIiS', guide_title: 'Decadent, Flavor-Packed Pork Belly', activity_slug: 'stupidly-simple-sous-vide-pork-belly'},
      {guide_id: 'pjfS2VQL9A8QIyG6uUeWe', guide_title: 'Easy, Delicious Sous Vide Yogurt', activity_slug: 'easy-delicious-sous-vide-yogurt'},
      {guide_id: '3aZDqgZMgosqGqmCwMKooW', guide_title: 'Flavor-Packed From-Scratch Corned Beef', activity_slug: 'nine-day-homemade-corned-beef'},
      {guide_id: '3kXWJim8FqKsC6AOy62M8C', guide_title: 'Flavor-Packed, Feast-Worthy Chuck Roast', activity_slug: 'flavor-packed-feast-worthy-chuck-roast'},
      {guide_id: '7fjWqUWSKk8K8ogKm4GGSU', guide_title: 'Foolproof Eggs Benedict', activity_slug: 'can-t-f-it-up-eggs-benedict'},
      {guide_id: '2KWkv8C4HKMgUeOiuIyWS8', guide_title: 'Foolproof Fried Chicken', activity_slug: 'can-t-f-it-up-fried-chicken'},
      {guide_id: 'k1LwSRPLkk2uYyKKUuWuG', guide_title: 'Hearty Apple-Braised Pork Shank', activity_slug: 'hearty-apple-braised-pork-shank'},
      {guide_id: '48FZLHVtTqauC4qK8YskY', guide_title: 'Heavenly Honey-Glazed Ham', activity_slug: 'homemade-honey-glazed-ham'},
      {guide_id: 'keiM4yv8OWIgwWOKiaisM', guide_title: 'Herb-Crusted Rib Roast (Prime Rib', activity_slug: 'win-the-holidays-with-herb-crusted-sous-vide-prime-rib-rib-roast'},
      {guide_id: '420uQsCNdmogU0qQISycoU', guide_title: 'Incredible Indoor Baby Back Ribs', activity_slug: 'smokerless-smoked-ribs-incredible-barbecue-no-smoker-required'},
      {guide_id: '6EbYSust1YmIaUyyWeU6Wy', guide_title: 'Killer Carne Asada', activity_slug: 'carne-asada-tacos-with-tender-flank-steak'},
      {guide_id: '5vORFmbDoWo8YEgiKmIWci', guide_title: 'Killer Confit Turkey Leg', activity_slug: 'crispy-tender-confit-turkey-legs'},
      {guide_id: '1X9tZJRWmkMm4cw2oAeMQg', guide_title: 'Korean-Style Beef Short Ribs (Kalbi', activity_slug: 'korean-style-barbecue-beef-short-ribs-kalbi'},
      {guide_id: '2uKGOgJlbSoI4UkqGqOO2Y', guide_title: 'Light, Bright Albacore Tuna Confit', activity_slug: 'albacore-confit-to-replace-that-sad-can-o-tuna'},
      {guide_id: '5OMl7DSpeo0E6mGSU2iMmC', guide_title: 'Make-Ahead Egg Bites for Breakfasts and Snacks', activity_slug: 'your-favorite-sous-vide-egg-bites-at-home'},
      {guide_id: '4LDt53bKik26y2Eqw4EWWw', guide_title: 'Olive Oil-Poached, Grill-Finished Octopus', activity_slug: 'tender-silky-sous-vide-octopus'},
      {guide_id: '54sdJItZ8I84MKAOiagqCc', guide_title: 'OMG, Its Braised Pork Belly Adobo', activity_slug: 'tender-decadent-pork-belly-adobo'},
      {guide_id: '2nRaLt8kROgASYSOO8mkUw', guide_title: 'One Lovely Leg of Lamb', activity_slug: 'mastering-leg-of-lamb-a-stress-free-technique-for-a-stunning-feast'},
      {guide_id: '2RMlQt8WMou2qAOe8I0IYm', guide_title: 'Perfectly Cooked, Crispy-Skinned Duck Breast', activity_slug: 'sous-vide-pork-chop'},
      {guide_id: '7myNe520ak4uI6cOcWUEqI', guide_title: 'Rhubarb Jam in a Jar', activity_slug: 'rhubarb-jam-in-a-jar'},
      {guide_id: '1dGGIbvRV2UaQCmwGqyeyY', guide_title: 'Simple, Tasty Pulled Pork Shoulder', activity_slug: 'wicked-good-pulled-pork-shoulder'},
      {guide_id: '7rh1MhFpHUkmaa4m0AqaWa', guide_title: 'Smokerless Smoked Brisket', activity_slug: 'smokerless-smoked-brisket'},
      {guide_id: '5FZ09rHxtek6gmOiQoGAe8', guide_title: 'Tender, Juicy Lamb Chops', activity_slug: 'tender-juicy-sous-vide-lamb-chops'},
      {guide_id: '2QThjvyyvum600uKcaAkwM', guide_title: 'Tender, Juicy Pork Tenderloin', activity_slug: 'pretty-pink-pork-tenderloin'},
      {guide_id: '6RQVyF6FwIKioYgmuQQoEK', guide_title: 'The Bombest Ever Braised Beef Short Ribs', activity_slug: 'bomb-braised-short-ribs'},
      {guide_id: 'vlFa41DfZA4Cw0iSyy8EE', guide_title: 'The Most Tender Turkey Breast Ever', activity_slug: 'the-most-tender-turkey-breast-ever'},
      {guide_id: '1WmWzfYnAIuIyigogsKi0s', guide_title: 'The World\'s Best Veal Osso Buco', activity_slug: 'the-world-s-best-osso-buco'},
      {guide_id: '1fUjfVGOEKc0amkwWQsAuK', guide_title: 'Ultimate Burger', activity_slug: 'sous-vide-burgers'},
      {guide_id: '795nOg0qBOE2aQk0M6gqUO', guide_title: 'Ultimate Carrots', activity_slug: 'sous-vide-carrots'},
      {guide_id: '8W1hBCq4LKAmOa0ckGWyQ', guide_title: 'Ultimate Center-Cut Tenderloin Roast', activity_slug: 'perfect-every-time-center-cut-tenderloin-roast'},
      {guide_id: '3GRdpdsDxukeiAue4Mgc84', guide_title: 'Ultimate Chicken Breast', activity_slug: 'sous-vide-chicken-breast'},
      {guide_id: '4hw0HcdJK0sOUeY4waiOE0', guide_title: 'Ultimate Chicken Thighs', activity_slug: 'crispy-chicken-thighs-made-simple-with-sous-vide'},
      {guide_id: '7dlsVpdSgwQyI4qIkE4qKg', guide_title: 'Ultimate Crispy Trout', activity_slug: 'crispy-whole-trout-with-greens-and-bacon'},
      {guide_id: '2Vxq5OUpziqY0MmqewGYoM', guide_title: 'Ultimate Salmon', activity_slug: 'sous-vide-salmon'},
      {guide_id: '35eu303TbWcSCcWIqEW0KA', guide_title: 'Ultimate Steak', activity_slug: 'sous-vide-steak'},
      {guide_id: '4EOWbuJcxW0WQsmA4e4siI', guide_title: 'Ultimate Steakhouse-Style Pork Chop', activity_slug: 'sous-vide-pork-chop'}
    ]

    existing.each do |e|
      activity = Activity.find(e[:activity_slug]) rescue nil
      if activity
        GuideActivity.create!({guide_id: e[:guide_id], guide_title: e[:guide_title], activity_id: activity.id, autoupdate: false})
      else
        puts "****************************** Activity #{e[:activity_slug]} not found"
      end
    end

  end

  def down
    drop_table :guide_activities
    remove_index :guide_activities, :guide_id
    remove_index :guide_activities, :activity_id
  end
end
