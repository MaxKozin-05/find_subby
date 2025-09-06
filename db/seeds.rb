user = User.find_or_create_by!(email: "test@test.com") { |u| u.password = "password" }
user.create_profile!(business_name: user.email.split("@").first.titleize) unless user.profile
