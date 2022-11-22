module Workflow
  # For definitions, there's interfaces done via admin UI.
  class Service
    # available work (returns processes/steps that are available)
    # sort based on long pole?

    # given a specific step, query what dependencies must be met
    # query 3rd party work (steps that are avaialble and waiting on not you)
    def self.run(*args)
      new(*args).run
    end

    class Error < StandardError
    end
  end
end
