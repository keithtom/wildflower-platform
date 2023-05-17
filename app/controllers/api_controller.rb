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
end
