module SSJ
  # helper class to hold phase logic
  class Phase
    PHASES = ["visioning", "planning", "startup"]

    def self.next(phase)
      case phase
      when "visioning"
        "planning"
      when "planning"
        "startup"
      when "startup"
        nil
      else
        raise "not a valid phase"
      end
    end
  end
end