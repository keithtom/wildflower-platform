class V1::UsersController < ApiController
  before_action :authenticate_admin!, only: [:destroy]

  def show
    @user = User.find_by!(external_identifier: params[:id])
    render json: V1::UserSerializer.new(@user, user_options)
  end

  def destroy
    @user = User.find_by!(external_identifier: params[:id])
    User::Offboard.new(@user, Date.today).run
    render json: { message: 'User deleted' }, status: :ok
  end

  private

  def user_options
    options = {}
    options[:include] = ['person', 'person.address']
    options
  end
end
