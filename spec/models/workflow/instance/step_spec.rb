require 'rails_helper'

RSpec.describe Workflow::Instance::Step, type: :model do
  describe "when step is copied over from definition" do
    subject { build(:workflow_instance_step) }
    let(:definition) { subject.definition }
    its(:title) { is_expected.to be == definition.title }
    its(:description) { is_expected.to be == definition.description }
    its(:kind) { is_expected.to be == definition.kind }
    its(:documents) { is_expected.to be == definition.documents }
    its(:position) { is_expected.to be == definition.position }
  end

  describe "when manual step is created" do
    subject { build(:workflow_instance_step_manual) }
    its(:definition) { is_expected.to be_nil }
    its(:documents) { is_expected.to_not be_empty }
  end
end
