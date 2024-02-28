class V1::Workflow::Definition::StepsController < ApiController
  before_action :authenticate_admin!

  def index
    steps = Workflow::Definition::Step.includes([:process]).all
    render json: V1::Workflow::Definition::StepSerializer.new(steps)
  end

  def show
    step = Workflow::Definition::Step.find(params[:id])
    render json: V1::Workflow::Definition::StepSerializer.new(step)
  end

  def create
    puts step_params.inspect
    step = Workflow::Definition::Step.create!(step_params)
    render json: V1::Workflow::Definition::StepSerializer.new(step)
  end

  def update
    step = Workflow::Definition::Step.find(params[:id])
    step.update!(step_params)
    # TODO run command that updates the instances
    render json: V1::Workflow::Definition::StepSerializer.new(step)
  end

  def destroy
    step = Workflow::Definition::Step.find(params[:id])
    step.destroy
    render json: { message: 'Step deleted successfully' }
  end

  private

  def step_params
    params.require(:step).permit(:process_id, :title, :description, :kind, :position, :completion_type, :decision_question)
  end
end