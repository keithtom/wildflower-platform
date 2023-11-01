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

  # this is arguably a workflow function.
  # step assignments index for a given workflow.
  # maybe let front end control the fields it wants. caller knows what it needs.
  # eager loading changes depending on what front end requests though.  fields and includes and eagerloading are coupled.
  # we can have short hands for the various combinations.  like param[:dashboard] = true
  # we are current hard coded to waht the todolist needs since htat's all it needs.
  def assigned_steps
    
    team = find_team
    
    # find all the incomplete assignments/steps for this partner and this specific workflow.
    eager_load_associations = [:assignee, step: [:documents, process: [:definition], assignments: [:step, :assignee], definition: [:decision_options, :documents]]]
    assignments = Workflow::Instance::StepAssignment.where(assignee_id: current_user.person_id).for_workflow(team.workflow_id).incomplete.includes(*eager_load_associations)
    steps = assignments.map { |assignment| assignment.step }

    # before we could group steps by 1 assignee, now we have multiple assignees per step so grouping that way doens't work
    # we can have assignment serializer handle serialization of steps, because it'd save us dual step serialization.
    
    serialization_options = {}
    serialization_options[:params] = { current_user: current_user }
    serialization_options[:include] = ['process', 'documents', 'assignments', 'assignments.assignee', 'decision_options']
    serialization_options[:fields] = {
      process: [:title],
      person: [:firstName, :lastName, :profileImageAttachment, :imageUrl],
    }

    render json: V1::Workflow::StepSerializer.new(steps, serialization_options)
  end

  # this can be a turned to a team resource
  def team
    if team = find_team
      render json: V1::SSJ::TeamSerializer.new(team, {include: ['partners']})
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

