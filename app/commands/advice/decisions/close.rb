class Advice::Decisions::Close < BaseService
  def initialize(decision)
    @decision = decision
  end

  def run
    # should only work from open.
    @decision.update(state: Advice::Decision::CLOSED)
  end
end
