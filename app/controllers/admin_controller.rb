class AdminController < ApiController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    if !current_user.is_admin
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
  end
end
