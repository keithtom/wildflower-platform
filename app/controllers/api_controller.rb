class ApiController < ActionController::API
  # before_action :authenticate_user! // removing for now, to unblock Taylor
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private
  def not_found
    head :not_found
  end
end
