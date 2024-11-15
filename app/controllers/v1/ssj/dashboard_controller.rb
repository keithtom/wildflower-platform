# TODO: rename this to pages controller since it is specific to front-end pages and optimized for drawing the front-end pages; not being a RESTful interface
class V1::SSJ::DashboardController < ApiController
  # helps draw the SSJ dashboard page.
  def progress
    processes = workflow.processes.eager_load(:prerequisites, :categories, steps: [:assignments],
                                                                           definition: %i[phase categories])

    assigned_steps_count = Workflow::Instance::StepAssignment.where(assignee_id: current_user.person_id).for_workflow(workflow_id).incomplete.count

    render json: V1::SSJ::ProcessProgressSerializer.new(processes).serializable_hash.merge(assigned_steps: assigned_steps_count)
  end

  # helps draw the SSJ resources page (resources are viewed as an SSJ specific concept)
  def resources
    process_ids = Workflow::Instance::Process.where(workflow_id: workflow.id).pluck(:id)
    steps = Workflow::Instance::Step.where(process_id: process_ids).includes(:documents,
                                                                             definition: %i[documents process])
    documents = steps.map { |step| step.documents }.flatten
    render json: V1::SSJ::ResourcesByCategorySerializer.new(documents)
  end
end
