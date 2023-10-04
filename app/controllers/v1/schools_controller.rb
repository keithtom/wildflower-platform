class V1::SchoolsController < ApiController
  def index
    @schools = School.includes(:banner_image_attachment, :logo_image_attachment, :pod, :people, :address, [:sister_schools], taggings: [:tag], school_relationships: [:person] ).all
    render json: V1::SchoolSerializer.new(@schools)
  end

  def show
    if params[:network] # for directory usage
      @school = School.includes(*optimized_query).find_by!(external_identifier: params[:id])
      render json: V1::SchoolSerializer.new(@school, school_options)
    else
      @school = School.includes(*optimized_query).find_by!(external_identifier: params[:id])
      render json: V1::SchoolSerializer.new(@school, school_options)
    end
  end

  def update
    school = School.includes(taggings: [:tag], school_relationships: [:person]).find_by!(external_identifier: params[:id])
    school.update!(school_params)
    render json: V1::SchoolSerializer.new(school.reload)
  end

  protected

  def school_options
    options = {
      include: [:people, :school_relationships, :address, :pod, :sister_schools]
    }
  end

  def optimized_query
    [
      :address, 
      :banner_image_attachment,
      :logo_image_attachment,
      [:sister_schools],
      taggings: [:tag], 
      school_relationships: [:person], 
      people: [:schools, :address, :hub, :profile_image_attachment, :school_relationships, taggings: [:tag]]
    ]
  end

  def school_params
    params.require(:school).permit(
      :banner_image,
      :logo_image,
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