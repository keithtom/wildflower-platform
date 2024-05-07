class V1::Workflow::Definition::SelectedProcessesController < ApiController
  before_action :authenticate_admin!

  # For now, only use this endpoint for position updates
  def update
    selected_process = Workflow::Definition::SelectedProcess.find(params[:id])

    begin
      ::Workflow::Definition::SelectedProcess::Reposition.run(selected_process, selected_process_params[:position])
    rescue Exception => e
      log_error(e)
      return render json: { message: e.message }, status: :unprocessable_entity
    end
    render json: V1::Workflow::Definition::SelectedProcessSerializer.new(selected_process.reload)
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