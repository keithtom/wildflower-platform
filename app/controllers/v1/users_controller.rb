class V1::UsersController < ApiController
  def show
    @user = User.find_by!(external_identifier: params[:id])
    render json: V1::UserSerializer.new(@user, user_options)
  end

  private

  def user_options
    options = {}
    options[:include] = ['person', 'person.address']
    return options
  end
end

