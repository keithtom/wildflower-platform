class V1::Workflow::Definition::SelectedProcessesController < ApiController
  before_action :authenticate_admin!

  # For now, only use this endpoint for position updates
  def update
    selected_process = Workflow::Definition::SelectedProcess.find(params[:id])

    if !selected_process.workflow.published?
      selected_process.reposition! unless selected_process.upgraded? # keep the state of an upgraded selected process, even after a position change
      selected_process.update!(selected_process_params)
      render json: V1::Workflow::Definition::SelectedProcessSerializer.new(selected_process.reload)
    else
      render json: 
        { error: "workflow published, please change position using other endpoint" }, 
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