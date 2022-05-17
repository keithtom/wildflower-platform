class Advice::Decisions::Amend < BaseService
  def initialize(decision)
    @decision = decision
  end

  def run
    # should only work from open.
    # should insert event, and record difference, new dates?, and null out people's records
    # requests advice again for the decision with attributes
  end
end
