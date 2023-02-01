class Users::AuthenticateViaToken < BaseCommand
  def initialize(token)
    @token = token
  end

  def call
    return false unless @user = find_user_by_token


    burn_token and return false unless valid_timestamp?

    burn_token

    @user
  end

  private

  def find_user_by_token
    User.find_by(authentication_token: @token)
  end

  def valid_timestamp?
    @user.authentication_token_at.between?(60.minutes.ago, Time.now)
  end

  def burn_token
    @user.authentication_token = nil
    @user.authentication_token_at = nil
    @user.save!
  end

end
