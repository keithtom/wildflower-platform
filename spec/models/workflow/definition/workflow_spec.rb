# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow, type: :model do
  describe "scopes" do
    describe ".latest_versions" do
      it "returns the latest versions of workflows" do
        # Create some workflow instances with different versions
        workflow_v1 = create(:workflow_definition_workflow, name: "basic", version: "v1")
        workflow_v2 = create(:workflow_definition_workflow, name: "independent", version: "v2")
        workflow_v3 = create(:workflow_definition_workflow, name: "charter", version: "v3")

        # Create another workflow with the same name but an older version
        older_workflow = create(:workflow_definition_workflow, name: workflow_v1.name, version: "v0")

        # Call the scope
        latest_workflows = Workflow::Definition::Workflow.latest_versions

        # Expect only the latest versions to be returned
        expect(latest_workflows).to contain_exactly(workflow_v3, workflow_v2, workflow_v1)
      end
    end
  end

  describe "published?" do
    it "returns true if the workflow is published" do
      workflow = create(:workflow_definition_workflow, published_at: Time.now)

      expect(workflow.published?).to be_truthy
    end

    it "returns false if the workflow is not published" do
      workflow = create(:workflow_definition_workflow, published_at: nil)

      expect(workflow.published?).to be_falsey
    end
  end

  describe ".validate_recurring" do
    context 'workflow is recurring' do
      context 'prev version is recurring' do
        let!(:prev_version_workflow) { create(:workflow_definition_workflow, recurring: true) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_workflow, previous_version: prev_version_workflow, recurring: true) }.not_to raise_error
        end
      end

      context 'prev version is NOT recurring' do
        let!(:prev_version_workflow) { create(:workflow_definition_workflow, recurring: false) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_workflow, previous_version: prev_version_workflow, recurring: true) }.to raise_error
        end
      end
    end
    context 'workflow is not recurring' do
      context 'prev version is recurring' do
        let!(:prev_version_workflow) { create(:workflow_definition_workflow, recurring: true) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_workflow, previous_version: prev_version_workflow, recurring: false) }.to raise_error
        end
      end

      context 'prev version is NOT recurring' do
        let!(:prev_version_workflow) { create(:workflow_definition_workflow, recurring: false) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_workflow, previous_version: prev_version_workflow, recurring: false) }.not_to raise_error
        end
      end
    end
  end
end