class Users::GenerateToken < BaseCommand
  def initialize(user)
    @user = user
  end

  def call
    # generate single click token for user with short expiry
    @user.authentication_token = generate_unique_token
    @user.authentication_token_at = Time.now
    @user.save!
    @user.authentication_token
  end

  private

  def generate_unique_token
    token = Devise.friendly_token until User.where(authentication_token: token).empty?
    token
  end
end
