class Admin::CreatePerson < BaseService
  def initialize(person_params)
    @person_params = person_params
  end

  def run
    ActiveRecord::Base.transaction do
      @person = Person.new(@person_params)
      @person.active = false
      @person.save!

      @user = User.new(email: @person.email, person: @person)
      @user.save!
    end

    send_invite_email
    @person
  end

  private

  def send_invite_email
    Users::SendInviteEmail.call(@user)
  end
end
