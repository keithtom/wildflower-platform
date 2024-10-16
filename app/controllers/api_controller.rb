require "highlight"

class ApiController < ActionController::API
  include Highlight::Integrations::Rails

  before_action :authenticate_user!
  around_action :with_highlight_context

  rescue_from ActiveRecord::RecordNotFound, with: :not_found  
  rescue_from Exception do |e|
    Highlight::H.instance.record_exception(e)
    raise
  end

  private
  def not_found
    head :not_found
  end

  def find_team
    SSJ::TeamMember.where(person_id: current_user.person_id, status: SSJ::TeamMember::ACTIVE).first&.ssj_team
  end

  def workflow_id
    find_team&.workflow_id
  end

  def workflow
    query = params[:workflow_id] ? { external_identifier: params[:workflow_id] } : { id: workflow_id }
    return Workflow::Instance::Workflow.find_by!(query)
  end

  def authenticate_admin!
    if !current_user.is_admin
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
  end
  
  def log_error(e)
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    Highlight::H.instance.record_exception(e)
  end
end
