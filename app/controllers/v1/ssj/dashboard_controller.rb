# TODO: rename this to pages controller since it is specific to front-end pages and optimized for drawing the front-end pages; not being a RESTful interface
class V1::SSJ::DashboardController < ApiController
  # helps draw the SSJ dashboard page.
  def progress
    processes = workflow.processes.eager_load(:prerequisites, :categories, steps: [:assignments], definition: [:phase, :categories])
    
    assigned_steps_count = Workflow::Instance::StepAssignment.where(assignee_id: current_user.person_id).for_workflow(workflow_id).incomplete.count

    render json: V1::SSJ::ProcessProgressSerializer.new(processes).serializable_hash.merge(assigned_steps: assigned_steps_count)
  end

  # helps draw the SSJ resources page (resources are viewed as an SSJ specific concept)
  def resources
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).includes(:documents, definition: [:documents, :process])
    documents = steps.map{|step| step.documents}.flatten
    render json: V1::SSJ::ResourcesByCategorySerializer.new(documents)
  end

  # this can be a turned to a team resource
  def invite_partner
    if team = find_team
      SSJ::InvitePartner.run(person_params, team, current_user)
      render json: V1::SSJ::TeamSerializer.new(team)
    else
      render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    end
  end

  # def add_partner
    # if team = SSJ::TeamMember.find_by!(person_id: current_user&.person.id, current: true, role: 'partner')&.ssj_team
      # SSJ::AddPartner.run(person_params, team, current_user)
      # render json: V1::SSJ::TeamSerializer.new(team)
    # else
      # render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    # end
  # end

  protected

  def person_params
    params.require(:person).permit(:email, :first_name, :last_name, :primary_language, :race_ethnicity_other, :lgbtqia,
                                   :gender, :pronouns, :household_income, :image_url, address_attributes: [:city, :state])
  end
end

