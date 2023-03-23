class V1::SSJ::DashboardController < ApiController
  def progress
    workflow = Workflow::Instance::Workflow.find_by!(id: workflow_id)
    processes = workflow.processes.eager_load(:prerequisites, :steps, :categories, definition: [:phase, :categories])
    render json: V1::SSJ::ProcessProgressSerializer.new(processes)
  end

  def resources
    workflow = Workflow::Instance::Workflow.find_by!(id: workflow_id)
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).includes(:documents, definition: [:documents, :process])
    documents = steps.map{|step| step.documents}.flatten
    render json: V1::SSJ::ResourcesByCategorySerializer.new(documents)
  end

  def assigned_steps
    workflow = Workflow::Instance::Workflow.find_by!(id: workflow_id)
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids, completed: false).where.not(assignee_id: nil).
      includes(:process, :documents, :selected_option, :assignee, definition: [:documents]).
      group_by{|step| step.assignee.external_identifier }

    options = {}
    options[:include] = ['documents', 'process']
    render json: V1::SSJ::AssignedStepsSerializer.new(steps, options)
  end

  def team
    if team = find_team
      render json: V1::SSJ::TeamSerializer.new(team)
    else
      render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    end
  end

  def update_team
    if team = find_team
      team.update!(team_params)
      render json: V1::SSJ::TeamSerializer.new(team)
    else
      render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    end
  end

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

