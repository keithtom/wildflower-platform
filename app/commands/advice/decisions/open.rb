class Advice::Decisions::Open < BaseService
  def initialize(decision)
    @decision = decision
  end

  def run
    # should only work from draft.
    @decision.update(state: Advice::Decision::OPEN)
  end
end
