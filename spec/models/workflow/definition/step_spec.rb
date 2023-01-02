require 'rails_helper'

RSpec.describe Workflow::Definition::Step, type: :model do
  describe "when step is created with no position" do
    let(:previous_step) { create(:workflow_definition_step, position: 1000 ) }
    subject { create(:workflow_definition_step, position: nil, process: previous_step.process) }
    its(:position) { is_expected.to be(previous_step.position + Workflow::Definition::Step::DEFAULT_INCREMENT) }
  end

  describe "when step is created with specified position" do
    let(:position) { 7000 }
    subject { create(:workflow_definition_step, position: position) }
    its(:position) { is_expected.to be(position) }
  end

  # describe "when kind is of type decision" do
    # subject { create(:workflow_definition_step, kind: Workflow::Definition::Step::DECISION) }
  # end
end
