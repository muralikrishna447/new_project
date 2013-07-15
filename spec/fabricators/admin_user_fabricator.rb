Fabricator :admin_user, from: User do
  email { sequence(:email) { |i| "admin_user#{i}@test.com"} }
  password 'secret'
  role 'admin'
  name 'Tokoo Forskoo'
end
