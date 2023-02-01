class Users::SendInviteEmail < BaseCommand
  def initialize(user)
    @user = user
  end

  def call
    generate_user_token
    send_invite_email
  end

  private

  def generate_user_token
    Users::GenerateToken.call(@user)
  end

  def send_invite_email
    UserMailer.with(user: @user).invite.deliver_later
  end
end
