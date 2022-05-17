class V1::Advice::DecisionsController < ApiController

  def index
    @person = Person.find_by!(external_identifier: params[:person_id])
    # needs options for order and eager loading (messages, events and records)
    @decisions = @person.decisions.includes(:stakeholders).order("updated_at DESC")
    # find a way to figure out if we are /draft/open/clsoed; and convert it into a standard url param.
    # @person.decisions # filter state if required.
    # routing should just rename /draft/open/close to a url param.

    # ideally no activities here to keep it light.
    render json: V1::Advice::DecisionSerializer.new(@decisions, include: [:stakeholders])
  end

  def open
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    Advice::Decisions::Open.run(@decision)
    render json: V1::Advice::DecisionSerializer.new(@decision)
  end

  def amend
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    Advice::Decisions::Amend.run(@decision)
    render json: V1::Advice::DecisionSerializer.new(@decision)
  end

  def close
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    Advice::Decisions::Close.run(@decision)
    render json: V1::Advice::DecisionSerializer.new(@decision)
  end

  def create
    # current_user = User.first
    # person = current_user.person || Person.first
    person = Person.first # just hacking this until we implement auth, it should be current user's person.
    # replace with a command?
    @decision = person.decisions.create!(decision_params)
    render json: V1::Advice::DecisionSerializer.new(@decision), :status => :created, :location => [:v1, @decision] # v1_advice_decision_url
  end

  def show
    # heavy upfront load use case jsut means eager load activities for each stakeholder.
    # stakeholders
    # activity will be eager loaded?  that's loading a lot more data per stakeholder.
    # better to just query all objects up front vs 10 stakeholder = 10 queries.
    # here we need to say include: [{:stakeholders => :activities}]

    # we can pass the param for acitivities in here...
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    render json: V1::Advice::DecisionSerializer.new(@decision)
  end

  def update
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    # replace with command?
    @decision.update(decision_params)
    render json: V1::Advice::DecisionSerializer.new(@decision)
  end

  protected

  def person_id
    params.permit(:person_id)
  end

  def decision_params
    params.require(:decision).permit(:title, :context, :proposal, :links, :decide_by, :advice_by, :role, :final_summary)
  end
end
