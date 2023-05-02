class Advice::Decisions::Amend < BaseService
  def initialize(decision, params)
    @decision = decision
    @params = params
  end

  def run
    # should only work from open.  emails every time again. (maybe make sure 2 requests don't happen sequentially?)
    if Advice::Decision::OPEN == @decision.state
      @decision.update(@params)
      # should insert event, and record difference, new dates?, and null out people's records
      # requests advice again for the decision with attributes
      # email ppl what changed and any date changes.
    else
      # closed or draft, likely an error
      raise "cannot open from #{@decision.state} state for decision #{@decision.external_identifier}"
    end
  end
end
