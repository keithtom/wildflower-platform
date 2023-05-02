require "highlight"

class ApiController < ActionController::API
  include Highlight::Integrations::Rails

  before_action :authenticate_user!
  around_action :with_highlight_context

  rescue_from ActiveRecord::RecordNotFound, with: :not_found  

  private
  def not_found
    head :not_found
  end

  def find_team
    current_user&.person&.ssj_team
  end

  def workflow_id
    find_team&.workflow_id
  end
end
