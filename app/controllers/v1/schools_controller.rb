class V1::SchoolsController < ApiController
  def index
    @schools = School.includes(:taggings, :pod, :school_relationships, :people, :address).all
    render json: V1::SchoolSerializer.new(@schools)
  end

  def search
    # eager load tags
    offset = search_params[:offset]
    limit = search_params[:limit]
    where = {}.merge(search_params[:school_filters] || {})
    query = search_params[:q]
    boost_where = {} # ideally boost local results first?
    tracking = {} # {user_id: current_user.id}
    @search = School.search(query, where: where, limit: limit, offset: offset, track: tracking)
    @schools = @search.to_a
    render json: V1::SchoolSerializer.new(@schools)
  end


  def show
    @school = School.find_by!(external_identifier: params[:id])
    render json: V1::SchoolSerializer.new(@school)
  end

  protected
  # advanced filters can do things like
  #   school_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  # audience = list of tags (used to be roles)
  def search_params
    params.require(:search).permit(:q, :audiences, :school_filters, :offset, :limit)
  end
end
