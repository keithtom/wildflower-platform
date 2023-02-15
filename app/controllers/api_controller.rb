class ApiController < ActionController::API
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private
  def not_found
    head :not_found
  end

  def workflow_id
    current_user&.person&.ssj_team&.workflow_id
  end
end
