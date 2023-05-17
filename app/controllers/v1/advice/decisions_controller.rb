class V1::Advice::DecisionsController < ApiController

  # find a way to figure out if we are /draft/open/clsoed; and convert it into a standard url param.
  # @person.decisions # filter state if required.
  # routing should just rename /draft/open/close to a url param.
  def index
    # scope to current user
    @person = Person.find_by!(external_identifier: params[:person_id])
    # needs options for order and eager loading (messages, events and records)
    @decisions = @person.decisions.includes(:documents, :stakeholders, :records, :creator, :events).order("updated_at DESC").all

    # each decision has its own last activity.
    # activities needed for 'last activity'
    activities_grouped_by_decision = Advice::Activities.run(@decisions, :decision)
    render json: V1::Advice::DecisionSerializer.new(@decisions, include: [:stakeholders, :documents],
      params: { activities_grouped_by_decision: activities_grouped_by_decision})
  end

  def create
    # current_user = User.first
    # person = current_user.person || Person.first
    @person = Person.find_by!(external_identifier: "2a09-fba2") # just hacking this until we implement auth, it should be current user's person.

    # replace with a command?
    @decision = @person.decisions.create!(decision_params.merge(state: "draft"))
    render json: V1::Advice::DecisionSerializer.new(@decision, include: [:stakeholders, :documents]), :status => :created, :location => [:v1, @decision] # v1_advice_decision_url
  end

  def show
    # scope to current user
    @decision = Advice::Decision.includes(:documents, :stakeholders, :messages, :events, :records).find_by!(external_identifier: params[:id])

    # activities needed for 'last activity'
    activities_grouped_by_decision = Advice::Activities.run([@decision], :decision)

    # if heavy upfront load option present, we have activities grouped by stakeholder.
    # heavy upfront load use case jsut means eager load activities for each stakeholder.
    activities_grouped_by_stakeholder = Advice::Activities.run(@decision, :stakeholder)

    render json: V1::Advice::DecisionSerializer.new(@decision, include: [:stakeholders, :documents],
      params: {
        activities_grouped_by_decision: activities_grouped_by_decision,
        activities_grouped_by_stakeholder: activities_grouped_by_stakeholder })
  end

  def update
    # scope to current user
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    # replace with command?
    @decision.update(decision_params)
    render json: V1::Advice::DecisionSerializer.new(@decision, include: [:stakeholders, :documents])
  end

  def open
    # scope to current user
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    result = Advice::Decisions::Open.run(@decision, open_decision_params)
    render json: V1::Advice::DecisionSerializer.new(@decision, include: [:stakeholders, :documents])
  end

  def amend
    # scope to current user
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    Advice::Decisions::Amend.run(@decision, amend_decision_params)
    render json: V1::Advice::DecisionSerializer.new(@decision, include: [:stakeholders, :documents])
  end

  def close
    # scope to current user
    @decision = Advice::Decision.find_by!(external_identifier: params[:id])
    Advice::Decisions::Close.run(@decision, close_decision_params)
    render json: V1::Advice::DecisionSerializer.new(@decision, include: [:stakeholders, :documents])
  end

  protected

  def decision_params
    params.require(:decision).permit(:title, :context, :proposal, :role)
  end

  def open_decision_params
    params.require(:decision).permit(:decide_by, :advice_by, :role)
  end

  def amend_decision_params
    params.require(:decision).permit(:changes_summary, :decide_by, :advice_by, :role)
  end

  def close_decision_params
    params.require(:decision).permit(:final_summary, :changes_summary, :role)
  end

end
