# TODO: rename this to pages controller since it is specific to front-end pages and optimized for drawing the front-end pages; not being a RESTful interface
class V1::SSJ::DashboardController < ApiController
  # helps draw the SSJ dashboard page.
  def progress
    workflow = Workflow::Instance::Workflow.find_by!(id: workflow_id)
    processes = workflow.processes.eager_load(:prerequisites, :steps, :categories, definition: [:phase, :categories])
    render json: V1::SSJ::ProcessProgressSerializer.new(processes)
  end

  # helps draw the SSJ resources page (resources are viewed as an SSJ specific concept)
  def resources
    workflow = Workflow::Instance::Workflow.find_by!(id: workflow_id)
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).includes(:documents, definition: [:documents, :process])
    documents = steps.map{|step| step.documents}.flatten
    render json: V1::SSJ::ResourcesByCategorySerializer.new(documents)
  end

  # this is arguably a workflow function.
  # step assignments index for a given workflow.
  def assigned_steps
    # TODO: this should just serialize into steps, let the front end sort out who assignees are; but that requires front-end work;
    
    team = find_team
    # find all the incomplete assignments/steps for this team's partners and this specific workflow.
    assignments  = Workflow::Instance::StepAssignment.where(assignee_id: team&.partner_ids).for_workflow(team.workflow_id).incomplete.includes(:assignee, :selected_option, step: [:process, :documents, definition: [:documents]])
    
    # before we could group steps by 1 assignee, now we have multiple assignees per step so grouping that way doens't work
    # we can have assignment serializer handle serialization of steps, because it'd save us dual step serialization.
    # or i somehow group the steps and put the completion/assignment info inside.
    # but i can manage that all on the front end.  
    # you just have the step and its assignee, and completion.  that's ideal.

    options = {}
    options[:include] = ['assignee', 'selected_option', 'step', 'step.documents', 'step.process']
    render json: V1::Workflow::StepAssignmentSerializer.new(assignments, options)
  end

  # this can be a turned to a team resource
  def team
    if team = find_team
      render json: V1::SSJ::TeamSerializer.new(team)
    else
      render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    end
  end

  # this can be a turned to a team resource
  def update_team
    if team = find_team
      team.update!(team_params)
      render json: V1::SSJ::TeamSerializer.new(team)
    else
      render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    end
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

  def team_params
    params.require(:team).permit(:expected_start_date)
  end

  def person_params
    params.require(:person).permit(:email, :first_name, :last_name, :primary_language, :race_ethnicity_other, :lgbtqia,
                                   :gender, :pronouns, :household_income, :image_url, address_attributes: [:city, :state])
  end
end

