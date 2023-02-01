class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: [:oogle_oauth2]

  def google_oauth2
    puts "################### i am in here"
    puts request.inspect
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in(resource_name, resource, store: false)
      redirect_to "#{redirect_url}/auth?jwt=#{request.env["warden-jwt_auth.token"]}"
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
      render json: {
        status: 401,
        message: @user.errors.full_messages.join("\n"),
      }, status: :unauthorized
    end
  end

  private

  def redirect_url
    # will pick up source_url if specified in the initial /auth/twitter request. If not set, fall back to defaults.
    request.env["omniauth.params"].dig("source_url") || (
      Rails.env.production? ? "https://platform.wildflowerschools.org/" : "http://localhost:3000")
  end
end
