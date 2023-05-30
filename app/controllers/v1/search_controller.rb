class V1::SearchController < ApplicationController

  def index
    # eager load tags
    offset = search_params[:offset]
    limit = search_params[:limit]
    where = {}.merge(search_params[:people_filters] || {}).merge(search_params[:school_filters]||{})
    query = search_params[:q]
    boost_where = {} # ideally boost local results first?
    tracking = {} # {user_id: current_user.id}
    model_whitelist = translate_models
    
    # jsonapi-serializer 2.0 only supports 1 model; 3.0 supports mixed collections of models
    # https://github.com/jsonapi-serializer/jsonapi-serializer/pull/141
    # for now, only query 1 model at a time.
    @search = Searchkick.search(query, models: model_whitelist, where: where, limit: limit, offset: offset, track: tracking)
    @results = @search.to_a
    
    render json: get_serializer.new(@results)
  end

  protected
  # advanced filters can do things like
  #   school_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  #   people_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  # audience = list of tags (used to be roles)
  # roles = list of tags (used to be skills)
  def search_params
    params.permit(:q, :models, :audiences, :roles, :people_filters, :school_filters, :offset, :limit)
  end

  # be as flexible as possible on consumption.
  def translate_models
    return [Person] unless params[:models]
    
    Array(params[:models]).flatten.map do |model|
      case model
      when 'person', 'people', 'persons'
        Person
      when 'school', 'schools'
        School
      else
        Rails.logger.warn "unsupported model: #{model}"
        nil
      end
    end.compact
  end

  def get_serializer
    return V1::PersonSerializer unless params[:models]
      
    case params[:models]
    when 'person', 'people', 'persons'
      V1::PersonSerializer
    when 'school', 'schools'
      V1::SchoolSerializer
    else
      raise "unsupported model: #{params[:models]}"
    end
  end
end
