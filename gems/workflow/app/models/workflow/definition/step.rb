module Workflow
  class Definition::Step < ApplicationRecord
    belongs_to :process
  end
end
