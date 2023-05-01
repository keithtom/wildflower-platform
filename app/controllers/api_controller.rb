class ApiController < ActionController::API
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  after_action :logging

  def logging
    puts "="*100
    puts "current user: #{current_user.external_identifier}"
  end


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
