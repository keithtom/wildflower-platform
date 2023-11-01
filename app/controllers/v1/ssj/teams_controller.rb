class V1::SSJ::TeamsController < ApiController
  before_action :authenticate_admin!, only: [:create, :index]

  def index
    teams = SSJ::Team.all.includes([:partner_members])
    render json: V1::SSJ::TeamSerializer.new(teams)
  end

  def show
    if team = SSJ::Team.find_by!(external_identifier: params[:id])
      render json: V1::SSJ::TeamSerializer.new(team, {include: ['partners']})
    else
      render json: { message: "current user is not part of team"}, status: :unprocessable_entity
    end
  end

  def create
    begin
      ops_guide = Person.find_by!(external_identifier: team_params[:ops_guide_id])
      rgl = Person.find_by!(external_identifier: team_params[:rgl_id])

      team = SSJ::InviteTeam.run(team_params[:etl_people_params], ops_guide, rgl)
      render json: { message: "team #{team.external_identifier} invite emails sent" }
    rescue => e
      render json: { message: e.message}, status: :unprocessable_entity
    end
  end

  def update
    if team = SSJ::Team.find_by!(external_identifier: params[:id])
      team.update!(team_params)
      render json: V1::SSJ::TeamSerializer.new(team)
    else
      render json: { message: "unable to update team"}, status: :unprocessable_entity
    end
  end

  private
  
  def team_params
    params.require(:team).permit(
      [:etl_people_params => [:first_name, :last_name, :email]],
      :ops_guide_id,
      :rgl_id,
      :expected_start_date
    )
  end
end