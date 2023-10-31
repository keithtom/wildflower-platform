class V1::PeopleController < ApiController
  def index
    @people = Person.includes(:hub, :profile_image_attachment, :schools, :address, taggings: [:tag]).all
    @people = @people.tagged_with("Ops Guide") if params[:ops_guide]
    @people = @people.tagged_with("Regional Entrepreneur") if params[:rgl]
    render json: V1::PersonSerializer.new(@people)
  end

  def show
    if params[:network] # for directory usage
      @person = Person.includes(:schools, :school_relationships).find_by!(external_identifier: params[:id])
      render json: V1::PersonSerializer.new(@person, include: [:schools, :school_relationships, :address])
    else
      @person = Person.find_by!(external_identifier: params[:id])
      render json: V1::PersonSerializer.new(@person)
    end
  end

  def update
    if current_user
      @person = current_user.person
      @person.update!(person_params)
      render json: V1::PersonSerializer.new(@person.reload)
    else
      render json: {
        status: 401,
        message: "Must be signed in"
      }, status: :unauthorized
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
                                   [:race_ethnicity_list => []],
                                   :race_ethnicity_other,
                                   :lgbtqia,
                                   :gender,
                                   :gender_other,
                                   :pronouns,
                                   :pronouns_other,
                                   :household_income,
                                   :montessori_certified,
                                   [:montessori_certified_level_list => []],
                                   [:classroom_age_list => []],
                                   [:role_list => []],
                                   :phone,
                                   :about,
                                   :is_onboarded,
                                   address_attributes: [:city, :state])
  end
end
