# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #  super
  # end

  # bug in devise for rails 7 https://github.com/heartcombo/devise/issues/5443
  def auth_options
    super.merge({store: false})
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # create a session via token
  def token
    if authenticated_user = Users::AuthenticateViaToken.call(params[:token])
      sign_in(authenticated_user)
      respond_with(authenticated_user)
    else
      render json: {
        status: 401,
        message: "Invalid token."
      }, status: :unauthorized
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  private

  def respond_with(resource, _opts = {})
    render json: V1::UserSerializer.new(resource, user_options), status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end

  def user_options
    options = {}
    options[:include] = ['person']
    return options
  end
end
