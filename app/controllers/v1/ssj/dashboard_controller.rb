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
    
    team = find_team
    
    # find all the incomplete assignments/steps for this partner and this specific workflow.
    assignments = Workflow::Instance::StepAssignment.where(assignee_id: current_user.person_id).for_workflow(team.workflow_id).incomplete.includes(:assignee, step: [:process, :documents, definition: [:documents]])
    steps = assignments.map { |assignment| assignment.step }

    # before we could group steps by 1 assignee, now we have multiple assignees per step so grouping that way doens't work
    # we can have assignment serializer handle serialization of steps, because it'd save us dual step serialization.
    
    serialization_options = {}
    serialization_options[:params] = { current_user: current_user }
    serialization_options[:include] = ['process', 'documents', 'assignments', 'assignments.assignee']

    render json: V1::Workflow::StepSerializer.new(steps, serialization_options)
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

