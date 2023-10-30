class V1::Admin::SSJController < AdminController
  def invite_team
    # TODO needs to be a check an admin is making the request
    begin
      ops_guide = Person.find_by!(external_identifier: team_params[:ops_guide_id])
      rgl = Person.find_by!(external_identifier: team_params[:rgl_id])

      team = SSJ::InviteTeam.run(team_params[:etl_people_params], ops_guide, rgl)
      render json: { message: "team #{team.external_identifier} invite emails sent" }
    rescue => e
      render json: { message: e.message}, status: :unprocessable_entity
    end
  end

  private
  
  def team_params
    params.require(:team).permit(
      [:etl_people_params => [:first_name, :last_name, :email]],
      :ops_guide_id,
      :rgl_id
    )
  end
end