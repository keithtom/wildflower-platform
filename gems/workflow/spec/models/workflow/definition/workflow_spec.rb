require 'rails_helper'

module Workflow
  RSpec.describe Definition::Workflow, type: :model do
    it { expect(Workflow::Definition::Workflow.new).to be_valid }

    # create a workflow from lib of processes and add dependencies.
  end
end
