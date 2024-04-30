class V1::Workflow::Definition::SelectedProcessesController < ApiController
  before_action :authenticate_admin!

  # For now, only use this endpoint for position updates
  def update
    selected_process = Workflow::Definition::SelectedProcess.find(params[:id])

    if selected_process.replicated? && !selected_process.workflow.published?
      selected_process.update!(selected_process_params)
      selected_process.reposition!
      render json: V1::Workflow::Definition::SelectedProcessSerializer.new(selected_process.reload)
    else
      render json: 
        { error: "Selected process state: #{selected_process.state}, workflow published: #{selected_process.workflow.published?}" }, 
        status: :unprocessable_entity
    end
  end

  def revert
    selected_process = Workflow::Definition::SelectedProcess.find(params[:selected_process_id])
    selected_process.revert!

    render json: V1::Workflow::Definition::SelectedProcessSerializer.new(selected_process)
  end

  private

  def selected_process_params
    params.require(:selected_process).permit(:position)
  end
end