Fabricator :admin_user do
  email { sequence(:email) { |i| "admin_user#{i}@test.com"} }
  password 'secret'
end
