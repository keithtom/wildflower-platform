class Advice::Decisions::Close < BaseService
  def initialize(decision, params)
    @decision = decision
    @params = params
  end

  def run
    # should only work from open.  it can be idempotent for close?
    if [Advice::Decision::OPEN, Advice::Decision::CLOSED].include?(@decision.state)
      @decision.update(@params.merge(state: Advice::Decision::CLOSED))
      # what other effects here?
    else
      # if it is in a draft state this seems like an error.
      raise "cannot close from #{@decision.state} state for decision #{@decision.external_identifier}"
    end
  end
end
