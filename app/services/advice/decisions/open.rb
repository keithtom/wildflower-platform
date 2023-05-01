class Advice::Decisions::Open < BaseService
  def initialize(decision, params)
    @decision = decision
    @params = params
  end

  def run
    # should only work from draft.  it can be idempotent for open?
    if [Advice::Decision::DRAFT, Advice::Decision::OPEN].include?(@decision.state)
      @decision.update(@params.merge(state: Advice::Decision::OPEN))
    else
      # if it is in a closed state this seems like an error.
      raise "cannot open from #{@decision.state} state for decision #{@decision.external_identifier}"
    end
  end
end
