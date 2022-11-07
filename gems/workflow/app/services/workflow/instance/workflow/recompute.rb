module Workflow
  class Instance::Workflow
    class Recompute
      # call when workflow definition has changed
      # compare definition to instances
      # insert new process/step instances while preserving what was completed
      #
      # also takes inputs to calculate applicability...
      #
      # also takes what's been completed
      # we must keep the entire graph on hand
      # we can see after what's been compelted, to easily update the state of ponteitla unlocked nodes
      #
      # keep history with a recompute event?
      # and give a reference to the recompute background job so users can query when its up to date.
    end
  end
end

# how to define applicability without domain logic in here?
# admin has to specific data points and potential values (includes, is exactly, etc)
# we expect a hash that's structured along that data definition.  it is a user defined schema.  they can map it to their own data model how they choose.
# its a rules engine.
# if rules pass, then it is applicable.
# if it fails, then don't mint it.

# auto completeabiltiy is really expensive bc they have to map far more data points.
#   (e.g. data driven rules.)
