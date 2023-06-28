class V1::SchoolsController < ApiController
  def index
    @schools = School.includes(:pod, :people, :address, taggings: [:tag], school_relationships: [:person] ).all
    render json: V1::SchoolSerializer.new(@schools)
  end

  def show
    if params[:network] # for directory usage
      options = {
        include: [:people, :school_relationships, :address, :pod]
      }
      @school = School.includes(:people, :school_relationships, taggings: [:tag]).find_by!(external_identifier: params[:id])
      render json: V1::SchoolSerializer.new(@school, options)
    else
      options = {
        include: [:address]
      }
      @school = School.includes(:address, taggings: [:tag]).find_by!(external_identifier: params[:id])
      render json: V1::SchoolSerializer.new(@school, options)
    end
  end

  def update
    school = School.includes(taggings: [:tag], school_relationships: [:person]).find_by!(external_identifier: params[:id])
    school.update!(school_params)
    render json: V1::SchoolSerializer.new(school.reload)
  end

  protected

  def school_params
    params.require(:school).permit(
      :about, 
      :opened_on, 
      [:ages_served_list => []], 
      :governance_type, 
      :max_enrollment, 
      :school_relationships_attributes => [:person_id],
      :address_attributes => [:city, :state]
    )
  end
end