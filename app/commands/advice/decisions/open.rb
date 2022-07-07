class Advice::Decisions::Open < BaseService
  def initialize(decision, open_decision_params)
    @decision = decision
    @open_decision_params = open_decision_params
  end

  def run
    # should only work from draft.  it can be idempotent for open?
    if [Advice::Decision::DRAFT, Advice::Decision::OPEN].include?(@decision.state)
      @decision.update(@open_decision_params.merge(state: Advice::Decision::OPEN))
    else
      # if it is in a closed state this seems like an error.
      raise "cannot open from #{@decision.state} state for decision #{@decision.external_identifier}"
    end
  end
end
