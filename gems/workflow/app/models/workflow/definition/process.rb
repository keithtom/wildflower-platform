module Workflow
  class Definition::Process < ApplicationRecord
    has_many :steps
  end
end
