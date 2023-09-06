module RedirectHelper
  def redirect_path(user)
    paths = {
      ssj: {is_onboarded: "/ssj", not_onboarded: "/welcome/new-etl"},
      non_ssj: {is_onboarded: "/network", not_onboarded: "/welcome/existing-member"}
    }
    user_type = user.person.ssj_team ? :ssj : :non_ssj
    onboarded_status = user.person.is_onboarded ? :is_onboarded : :not_onboarded
    paths[user_type][onboarded_status]
  end
end