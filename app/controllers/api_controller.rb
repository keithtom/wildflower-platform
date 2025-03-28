require 'highlight'

class ApiController < ActionController::API
  include Highlight::Integrations::Rails

  before_action :authenticate_user!
  around_action :with_highlight_context

  rescue_from Exception do |e|
    Highlight::H.instance.record_exception(e)
    raise
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { message: 'Record not found' }, status: :not_found
  end

  def find_team
    SSJ::TeamMember.where(person_id: current_user.person_id, status: SSJ::TeamMember::ACTIVE).first&.ssj_team
  end

  def workflow_id
    return Workflow::Instance::Workflow.find_by!(external_identifier: params[:workflow_id]) if params[:workflow_id]

    find_team&.workflow_id
  end

  def workflow
    query = params[:workflow_id] ? { external_identifier: params[:workflow_id] } : { id: workflow_id }
    Workflow::Instance::Workflow.find_by!(query)
  end

  def authenticate_admin!
    render json: { message: 'Unauthorized' }, status: :unauthorized unless current_user.is_admin
  end

  def log_error(e)
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    Highlight::H.instance.record_exception(e)
  end
end
