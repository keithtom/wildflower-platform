class Users::SendInviteEmail < BaseCommand
  def initialize(user)
    @user = user
  end

  # sends an email to invite the user to the system; contains a single-click login link.
  def call
    generate_user_token
    send_invite_email
  end

  private

  def generate_user_token
    Users::GenerateToken.call(@user)
  end

  def send_invite_email
    SSJMailer.invite(@user).deliver_later
  end
end
