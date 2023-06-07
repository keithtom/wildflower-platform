class V1::SearchController < ApplicationController

  def index
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

    # open date - not yet open, 0-2, 3-4, 5+ years
    # 
    case params[:models]
    when 'person', 'people', 'persons'
      # people where
      # based on the keys above, build the right where clause using a language of OR
      @search = Person.search(query, where: where, limit: limit, offset: offset, track: tracking, includes: [:taggings, :address, school_relationships: [:school]])
      @results = @search.to_a
      render json: V1::PersonSerializer.new(@results)
    when 'school', 'schools'
      @search = School.search(query, where: where, limit: limit, offset: offset, track: tracking, includes: [:taggings, :address, school_relationships: [:people]])
      @results = @search.to_a
      render json: V1::SchoolSerializer.new(@results, include: [:people, :school_relationships, :address, :pod])
    else
      @search = Person.search(query, models: model_whitelist, where: where, limit: limit, offset: offset, track: tracking, includes: [:taggings, :address, school_relationships: [:school]])
      @results = @search.to_a
      render json: V1::PersonSerializer.new(@results, include: [:schools, :school_relationships, :address])
    end
  end

  protected
  # advanced filters can do things like
  #   school_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  #   people_filters[group]= values; e.g. { tuition_assistance_type => ['state vouchers', 'county childcare']}
  # roles = list of tags (used to be skills)
  
  # filters for different entities.  what's a good search API?
  # q, models, offset, limit, general stuff
  # but then there's specific filters for each entity in where
  def search_params
    params.permit(:q, :models, :role_list, :people_filters, :school_filters, :offset, :limit)
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

  def interpret_people_filters
    where = {}
    where.merge!(address_state: params[:people_filters][:address_states]) if params[:people_filters][:address_states].present?
    where.merge!(primary_language: params[:people_filters][:languages]) if params[:people_filters][:primary_languages].present?
    if params[:people_filters][:roles].present?
      where_roles = params[:people_filters][:roles].map { |role| {roles: { ilike: "%#{role}%" }} }
      where.merge!(_or: where_roles)
    end
    if params[:people_filters][:race_ethnicities].present?
      where_race_ethnicity = params[:people_filters][:race_ethnicities].map { |race_ethnicity| { race_ethnicity: { ilike: "%#{race_ethnicity}%" } } }
      where.merge!(_or: where_race_ethnicity)
    end
    where.merge!(gender: params[:people_filters][:genders]) if params[:people_filters][:genders]
    where
  end

  def interpret_school_filters
  end
end
