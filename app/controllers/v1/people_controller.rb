class V1::PeopleController < ApiController
  def index
    # eager load tags
    @people = Person.all
    render json: V1::PersonSerializer.new(@people)
  end

  def search
    # eager load tags
    offset = search_params[:offset]
    limit = search_params[:limit]
    where = {}.merge(search_params[:people_filters] || {}).merge(search_params[:school_filters]||{})
    query = search_params[:q]
    boost_where = {} # ideally boost local results first?
    tracking = {} # {user_id: current_user.id}
    @search = Person.search(query, where: where, limit: limit, offset: offset, track: tracking)
    @people = @search.to_a
    render json: V1::PersonSerializer.new(@people)
  end

  def show
    @person = Person.find_by!(external_identifier: params[:id])
    render json: V1::PersonSerializer.new(@person)
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
  # advanced filters can do things like
  #   people_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  # audience = list of tags (used to be roles)
  # roles = list of tags (used to be skills)
  def search_params
    params.require(:search).permit(:q, :audiences, :roles, :people_filters, :school_filters, :offset, :limit)
  end

  def person_params
    params.require(:person).permit(:profile_image,
                                   :first_name,
                                   :last_name,
                                   :email,
                                   :primary_language,
                                   :race_ethnicity_other,
                                   :lgbtqia,
                                   :gender,
                                   :prounouns,
                                   :household_income,
                                   address_attributes: [:city, :state])
  end
end
