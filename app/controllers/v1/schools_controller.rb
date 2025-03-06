class V1::SchoolsController < ApiController
  before_action :authenticate_admin!, only: [:create]

  def index
    status = filter_params[:status]
    person_id = Person.find_by(external_identifier: filter_params[:person_id])&.id
    role = filter_params[:role]
    serialization_options = {}

    query = School
    includes = [:banner_image_attachment, :logo_image_attachment, :pod, :people, :address,
                               [:workflow], [:sister_schools], { taggings: [:tag], school_relationships: [:person] }]
    if filter_params[:name_only]
      serialization_options = { fields: { school: [:name] } }
      includes = [[]]
    end

    if person_id
      school_id_query = SchoolRelationship.where(person_id:)
      school_id_query = school_id_query.tagged_with(role) if role
      @schools = query.where(id: school_id_query.pluck(:school_id)).includes(*includes)
    else
      @schools = query.all.includes(*includes)
    end

    @schools = @schools.where(status:) if status

    render json: V1::SchoolSerializer.new(@schools, serialization_options)
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
    school = School.includes(:taggings,
                             school_relationships: [:person]).find_by!(external_identifier: params[:id])
    school.update!(school_params)
    render json: V1::SchoolSerializer.new(school.reload)
  end

  def create
    ops_guide = Person.find_by!(external_identifier: school_params[:ops_guide_id])
    rgl = Person.find_by!(external_identifier: school_params[:rgl_id])

    school = SSJ::InviteSchool.run(school_params[:etl_people_params], school_params[:workflow_id], ops_guide, rgl)
    render json: { message: "school #{school.external_identifier} invite emails sent" }
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def invite_partner
    school = School.includes(taggings: [:tag],
                             school_relationships: [:person]).find_by!(external_identifier: params[:school_id])
    begin
      School::InvitePartner.run(person_params, school_relationship_params, school, current_user)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::SchoolSerializer.new(school.reload, school_options)
  end

  def reinvite_partner
    school = School.includes(taggings: [:tag],
                             school_relationships: [:person]).find_by!(external_identifier: params[:school_id])
    person = Person.find_by!(external_identifier: person_params['id'])
    begin
      School::ReinvitePartner.run(person, school, current_user)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::SchoolSerializer.new(school.reload, school_options)
  end

  def remove_partner
    school = School.find_by!(external_identifier: params[:school_id])
    person = Person.find_by!(external_identifier: person_params['id'])
    end_date = person_params[:end_date]&.to_date

    begin
      School::RemovePartner.run(person, school, end_date)
    rescue Exception => e
      log_error(e)
      render json: { error: e.message }, status: :unprocessable_entity
      return
    end

    render json: V1::SchoolSerializer.new(school.reload, school_options)
  end

  protected

  def school_options
    options = {
      include: %i[people school_relationships school_relationships.person address pod sister_schools]
    }
  end

  def person_params
    params.require(:person).permit(:id, :email, :first_name, :last_name, :end_date)
  end

  def school_relationship_params
    return nil unless params[:school_relationship]

    params.require(:school_relationship).permit(:title, :start_date, :end_date)
  end

  def optimized_query
    [
      :address,
      :banner_image_attachment,
      :logo_image_attachment,
      [:workflow],
      [:sister_schools],
      { taggings: [:tag],
        school_relationships: [:person],
        people: [:schools, :address, :profile_image_attachment, :school_relationships, { taggings: [:tag] }] }
    ]
  end

  def school_params
    params.require(:school).permit(
      [etl_people_params: %i[first_name last_name email]],
      :workflow_id,
      :ops_guide_id,
      :rgl_id,
      :expected_start_date,
      :banner_image,
      :logo_image,
      :about,
      :opened_on,
      :expected_start_date,
      [ages_served_list: []],
      :governance_type,
      :max_enrollment,
      :num_classrooms,
      :charter_string,
      :directory_visible,
      school_relationships_attributes: [:person_id],
      address_attributes: %i[city state]
    )
  end

  def filter_params
    params.permit(:person_id, :status, :role, :name_only)
  end
end
