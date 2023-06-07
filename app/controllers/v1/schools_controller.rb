class V1::SchoolsController < ApiController
  def index
    @schools = School.includes(:taggings, :pod, :people, :address, school_relationships: [:person] ).all
    render json: V1::SchoolSerializer.new(@schools)
  end

  def show
    if params[:network] # for directory usage
      @school = School.includes(:people, :school_relationships).find_by!(external_identifier: params[:id])
      render json: V1::SchoolSerializer.new(@school, include: [:people, :school_relationships, :address, :pod])
    else
      @school = School.includes(:people).find_by!(external_identifier: params[:id])
      render json: V1::SchoolSerializer.new(@school)
    end
  end
end
