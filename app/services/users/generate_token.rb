class Users::GenerateToken < BaseCommand
  def initialize(user)
    @user = user
  end

  # generate single click auth token for user with short expiry
  def call
    @user.reset_authentication_token! # from Devise::TokenAuthenticatable gem
    @user.authentication_token
  end
end
