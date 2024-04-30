class V1::Workflow::Definition::SelectedProcessesController < ApiController
  before_action :authenticate_admin!

  def revert
    selected_process = Workflow::Definition::SelectedProcess.find(params[:selected_process_id])
    selected_process.revert!

    render json: V1::Workflow::Definition::SelectedProcessSerializer.new(selected_process)
  end
end