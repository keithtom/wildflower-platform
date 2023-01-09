class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: :google

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in(resource_name, resource, store: false)
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
      render json: {
        status: 401,
        message: @user.errors.full_messages.join("\n"),
      }, status: :unauthorized
    end
  end
end