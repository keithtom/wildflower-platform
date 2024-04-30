class V1::Workflow::DecisionOptionsController < ApiController
  before_action :authenticate_admin!

  def destroy
    decision_option = Workflow::DecisionOption.find(params[:id])
    decision_option.destroy!
    render json: { message: 'Successfully deleted decision option'}
  end
end