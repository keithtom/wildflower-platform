require 'rails_helper'

RSpec.describe Workflow::Instance::Step, type: :model do
  describe "when manual step is created" do
    subject { build(:workflow_instance_step_manual) }
    its(:definition) { is_expected.to be_nil }
    its(:documents) { is_expected.to_not be_empty }
  end

  describe "when manual step is created with no position" do
    let(:previous_step) { create(:workflow_instance_step) }
    subject { create(:workflow_instance_step_manual, position: nil, process: previous_step.process) }
    its(:position) { is_expected.to be(previous_step.position + Workflow::Definition::Step::DEFAULT_INCREMENT) }
  end

  describe "when manual step is created with specified position" do
    let(:position) { 7000 }
    subject { create(:workflow_instance_step_manual, position: position) }
    its(:position) { is_expected.to be(position) }
  end
end

# if a step is a manual step, it cannot be of type decision
# if a step is a decision, it should have multiple options 
# once user decides which step to take, it should be recorded
