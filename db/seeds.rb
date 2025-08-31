User.find_or_create_by!(email: 'test@test.com') do |u|
  u.password = 'password'
  u.role = :admin
  u.plan = :pro
end
