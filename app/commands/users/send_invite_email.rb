class Users::SendInviteEmail < BaseService
  def initialize(user)
    @user = user
  end

  def run
    # generate single click token for user with short expiry
    # send invite email
  end

  private

  def send_invite_email
    UserMailer.with(user: @user).invite.deliver_later
  end
end
