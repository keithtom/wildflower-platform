class Api::V1::SchoolsController < ApiController
  def index
    @schools = School.all
    render json: V1::SchoolSerializer.new(@schools)
  end

  def show
    @school = School.find_by!(external_identifier: params[:id])
    render json: V1::SchoolSerializer.new(@school)
  end
end
