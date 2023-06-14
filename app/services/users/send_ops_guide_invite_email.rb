class Users::SendOpsGuideInviteEmail < BaseCommand
  def initialize(user, team)
    @user = user
    @team = team
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
    SSJMailer.invite_ops_guide(@user, @team).deliver_later
  end
end
