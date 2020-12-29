Fabricator(:shop_menu, from: Menu ) do
  id 1
  name      "Shop"
  url       "/shop"
  position 1
  is_studio true
  is_premium true
  is_not_logged true
end

Fabricator(:recipe_menu, from: Menu ) do
  id 2
  name      "Recipe"
  url       "/gallery"
  position 2
  is_studio true
  is_premium true
  is_free true
  is_not_logged true
end

Fabricator(:studiopass_menu, from: Menu ) do
  id 3
  name      "StudioPass"
  url       "/studio_pass"
  position 3
  is_studio true
  is_premium true
end

Fabricator(:premium_menu, from: Menu ) do
  id 4
  name      "Premium"
  url       "/premium"
  position 4
  is_premium true
end

Fabricator(:not_logged_menu, from: Menu ) do
  id 5
  name      "Not Logged"
  url       "/not_logged_menu"
  position 5
  is_not_logged true
end

Fabricator(:cuts, from: Menu ) do
  id 6
  name      "Cuts"
  url       "/cuts"
  position 6
  is_studio true
  is_premium true
end

Fabricator(:beef_without_bone, from: Menu ) do
  id 7
  name      "Beef Without bone"
  url       "/beef_without_bone"
  parent_id 6
  position 1
  is_studio true
  is_premium true
end

Fabricator(:beef_with_bone, from: Menu ) do
  id 8
  name      "Beef With bone"
  url       "/beef_with_bone"
  parent_id 6
  position 2
  is_studio true
  is_premium true
end

Fabricator(:free_menu, from: Menu ) do
  id 9
  name      "free"
  url       "/free"
  position 7
  is_free true
end

Fabricator(:dummy_menu, from: Menu ) do
  id 10
  name      "dummy_menu"
  url       "/dummy_menu"
  position 8
end
