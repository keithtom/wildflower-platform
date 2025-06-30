class V1::PeopleController < ApiController
  before_action :authenticate_admin!, only: %i[create destroy]

  def index
    @people = Person.includes(:profile_image_attachment, :schools, :address, taggings: [:tag])
    @people = @people.tagged_with(Person::OPS_GUIDE) if params[:ops_guide]
    @people = @people.tagged_with(Person::RGL) if params[:rgl]

    page = [params[:page].to_i, 1].max
    per_page = [[params[:per_page].to_i, 1].max, 100].min
    per_page = 25 if per_page == 1 && !params[:per_page].to_i.positive?

    if params[:etl]
      @people = @people.tagged_with(Person::ETL)
      paginated_people = @people.order(first_name: :asc).paginate(page:, per_page:)
      render json: V1::PersonBasicSerializer.new(paginated_people, meta: pagination_meta(paginated_people))
    elsif params[:lightweight]
      paginated_people = @people.order(first_name: :asc).paginate(page:, per_page:)
      render json: V1::PersonBasicSerializer.new(paginated_people, meta: pagination_meta(paginated_people))
    else
      paginated_people = @people.order(first_name: :asc).paginate(page:, per_page:)
      render json: V1::PersonSerializer.new(paginated_people, meta: pagination_meta(paginated_people))
    end
  end

  def create
    begin
      @person = Admin::CreatePerson.run(person_params)
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      return
    end

    render json: V1::PersonSerializer.new(@person), status: :created
  end

  def show
    if params[:network] # for directory usage
      @person = Person.includes(taggings: [:tag]).find_by!(external_identifier: params[:id])
      render json: V1::PersonSerializer.new(@person,
                                            { include: %i[schools school_relationships address],
                                              params: { network: true } })
    elsif params[:included]
      @person = Person.find_by!(external_identifier: params[:id])
      render json: V1::PersonSerializer.new(@person, {
                                              include: %i[schools school_relationships]
                                            })
    else
      @person = Person.find_by!(external_identifier: params[:id])
      render json: V1::PersonSerializer.new(@person)
    end
  end

  def update
    @person = Person.find_by!(external_identifier: params[:id])

    if @person.user == current_user || current_user.is_admin
      @person.update!(person_params)
      render json: V1::PersonSerializer.new(@person.reload)
    else
      render json: {
        status: 401,
        message: 'Must be signed in'
      }, status: :unauthorized
    end
  end

  def destroy
    @person = Person.find_by!(external_identifier: params[:id])
    begin
      People::Offboard.run(@person, Date.today)
      render json: { message: 'Person removed' }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  protected

  def person_params
    params.require(:person).permit(:profile_image,
                                   :first_name,
                                   :last_name,
                                   :email,
                                   :primary_language,
                                   :primary_language_other,
                                   :preferred_language,
                                   [race_ethnicity_list: []],
                                   :race_ethnicity_other,
                                   :lgbtqia,
                                   :gender,
                                   :gender_other,
                                   :pronouns,
                                   :pronouns_other,
                                   :household_income,
                                   :montessori_certified,
                                   :montessori_certified_year,
                                   [montessori_certified_level_list: []],
                                   [classroom_age_list: []],
                                   [role_list: []],
                                   :phone,
                                   :about,
                                   :active,
                                   :is_onboarded,
                                   address_attributes: %i[city state])
  end

  private

  def pagination_meta(paginated_object)
    {
      current_page: paginated_object.current_page,
      per_page: paginated_object.per_page,
      total_entries: paginated_object.total_entries,
      total_pages: paginated_object.total_pages
    }
  end
end
