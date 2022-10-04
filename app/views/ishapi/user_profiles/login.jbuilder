
json.email     @current_profile.email
json.n_unlocks @current_profile.n_unlocks
json.jwt_token @jwt_token
json.partial!  'ishapi/user_profiles/account', profile: @current_profile
