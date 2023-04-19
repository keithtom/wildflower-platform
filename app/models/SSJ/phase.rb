module SSJ
  # helper class to hold phase logic
  class Phase
    PHASES = [VISIONING = "visioning", PLANNING = "planning", STARTUP = "startup"]

    def self.next(phase)
      case phase
      when VISIONING
        PLANNING
      when PLANNING
        STARTUP
      when STARTUP
        nil
      else
        raise "not a valid phase"
      end
    end
  end
end