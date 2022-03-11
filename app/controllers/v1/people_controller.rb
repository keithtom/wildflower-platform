class V1::PeopleController < ApiController
  def index
    # eager load tags
    @people = Person.all
    render json: V1::PersonSerializer.new(@people)
  end


  def search
    # eager load tags
    offset = 0
    limit = nil
    where = {}.merge(search_params[:people_filters]).merge(search_params[:school_filters])
    query = search_params[:q]
    boost_where = {} # ideally boost local results first?
    tracking = {user_id: current_user.id}
    @people = People.search(query, where: where, limit: limit, offset: offset, track: tracking)
    render json: V1::PersonSerializer.new(@people)
  end

  def show
    @person = Person.find_by!(external_identifier: params[:id])
    render json: V1::PersonSerializer.new(@person)
  end

  protected
  # advanced filters can do things like
  #   people_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  # audience = list of tags (used to be roles)
  # roles = list of tags (used to be skills)
  def search_params
    params[:people].permit(:q, :audiences, :roles, :people_filters, :school_filters)
  end
end
