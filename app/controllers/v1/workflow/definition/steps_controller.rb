class V1::Workflow::Definition::StepsController < ApiController
  before_action :authenticate_admin!

  def show
    step = Workflow::Definition::Step.find(params[:id])
    render json: V1::Workflow::Definition::StepSerializer.new(step, serializer_options)
  end

  def create
    process = Workflow::Definition::Process.find_by!(id: params[:process_id])
    step = Workflow::Definition::Step.create!(step_params.merge!(process_id: process.id))
    render json: V1::Workflow::Definition::StepSerializer.new(step, serializer_options)
  end

  def update
    step = Workflow::Definition::Step.find_by!(id: params[:id], process_id: params[:process_id])

    begin
      if step&.process&.published? # if process is published, its an instantaneous change
        Workflow::Definition::Step::PropagateInstantaneousChange.run(step, step_params)
      else
        Workflow::Definition::Step::Update.run(step, step_params)
      end
    rescue Exception => e
      log_error(e)
      return render json: { message: e.message }, status: :unprocessable_entity
    end

    render json: V1::Workflow::Definition::StepSerializer.new(step.reload, serializer_options)
  end

  def destroy
    step = Workflow::Definition::Step.find(params[:id])
    step.destroy
    render json: { message: 'Step deleted successfully' }
  end

  private

  def step_params
    params.require(:step).permit(:process_id, :title, :description, :kind, :position, :completion_type, :min_worktime, :max_worktime,
    :decision_question, decision_options_attributes: [:id, :description], documents_attributes: [:id, :title, :link])
  end

  def serializer_options
    { include: ['documents', 'decision_options']}
  end
end