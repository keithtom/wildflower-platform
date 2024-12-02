class V1::Workflow::Definition::WorkflowsController < ApiController
  include WorkflowAttributes

  before_action :authenticate_admin!

  def index
    workflows = Workflow::Definition::Workflow.latest_versions
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflows, serializer_options)
  end

  def show
    workflow = Workflow::Definition::Workflow.find(params[:id])
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow,
                                                                  serializer_options.merge!({ params: { workflow_id: params[:id] } }))
  end

  def create
    workflow = Workflow::Definition::Workflow.create!(workflow_params)
    render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow,
                                                                  serializer_options.merge!({ params: { workflow_id: params[:id] } }))
  end

  def update
    workflow = Workflow::Definition::Workflow.find(params[:id])
    if workflow.published?
      render json: { message: 'Cannot update a published workflow' }, status: :unprocessable_entity
    else
      workflow.update!(workflow_params)
      render json: V1::Workflow::Definition::WorkflowSerializer.new(workflow,
                                                                    serializer_options.merge!({ params: { workflow_id: params[:id] } }))
    end
  end

  def destroy
    workflow = Workflow::Definition::Workflow.find(params[:id])
    if workflow.published? || !workflow.instances.count.zero?
      render json: { message: 'Cannot delete a published workflow' }, status: :unprocessable_entity
    else
      workflow.destroy!
      # TODO: need to destroy the selected processes, and dependencies
      render json: { message: 'Successfully deleted workflow' }
    end
  end

  def new_version
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    new_version = Workflow::Definition::Workflow::NewVersion.run(workflow)

    render json: V1::Workflow::Definition::WorkflowSerializer.new(new_version,
                                                                  serializer_options.merge!({ params: { workflow_id: params[:id] } }))
  end

  def publish
    begin
      Workflow::Definition::Workflow::Publish.new(params[:workflow_id]).validate
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    PublishWorkflowJob.perform_later(params[:workflow_id])
    render json: { message: 'Rollout in progress' }
  end

  def create_process
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    begin
      process = Workflow::Definition::Workflow::CreateProcess.run(workflow, process_params)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::Workflow::Definition::ProcessSerializer.new(process,
                                                                 { include: %w[steps selected_processes
                                                                               prerequisites] })
  end

  def add_process
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    process = Workflow::Definition::Process.find(params[:process_id])
    position = nil
    if process_params[:selected_processes_attributes]
      position = process_params[:selected_processes_attributes].last[:position]
    end

    begin
      Workflow::Definition::Workflow::AddProcess.run(workflow, process, position)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::Workflow::Definition::ProcessSerializer.new(process.reload,
                                                                 { include: %w[steps selected_processes
                                                                               prerequisites] })
  end

  def remove_process
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    process = Workflow::Definition::Process.find(params[:process_id])

    begin
      Workflow::Definition::Workflow::RemoveProcess.run(workflow, process)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: { message: 'Successfully removed process' }
  end

  def new_process_version
    workflow = Workflow::Definition::Workflow.find(params[:workflow_id])
    process = Workflow::Definition::Process.find(params[:process_id])

    begin
      new_version = Workflow::Definition::Process::NewVersion.run(workflow, process)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::Workflow::Definition::ProcessSerializer.new(new_version,
                                                                 { include: %w[steps selected_processes
                                                                               prerequisites] })
  end

  private

  def workflow_params
    params.require(:workflow).permit(:version, :name, :description)
  end

  def process_params
    params.require(:process).permit(process_attributes)
  end

  def serializer_options
    { include: ['processes', 'processes.selected_processes'] }
  end
end
