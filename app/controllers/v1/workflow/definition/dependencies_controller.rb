class V1::Workflow::Definition::DependenciesController < ApiController
  before_action :authenticate_admin!

  def destroy
    dependency = Workflow::Definition::Dependency.find(params[:id])
    dependency.destroy!
    render json: { message: 'Successfully deleted dependency'}
  end
end