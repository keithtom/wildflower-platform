class V1::Admin::SSJController < ApplicationController
  def invite_team
    begin
      team = SSJ::InviteTeam.run(params[:etl_people_params], params[:ops_guide_email], params[:rgl_email])
      render json: { message: "team #{team.external_identifier} invite emails sent" }
    rescue => e
      render json: { message: e.message}, status: :unprocessable_entity
    end
  end
end
