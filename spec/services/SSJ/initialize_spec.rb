require "rails_helper"

describe SSJ::Initialize do
  let(:workflow_definition) { create(:workflow_definition_workflow) }
  let(:process_definition) { create(:workflow_definition_process, category_list: "coffee") }
  let(:prerequisite_definition) { create(:workflow_definition_process, phase_list: "tea") }
  let!(:dependency_definition) { create(:workflow_definition_dependency, workflow: workflow_definition, workable: process_definition, prerequisite_workable: prerequisite_definition)}
  let!(:step_definition) { create(:workflow_definition_step, process: process_definition) }
  let!(:step2_definition) { create(:workflow_definition_step, process: prerequisite_definition) }

  before do
    workflow_definition.processes << process_definition
    workflow_definition.processes << prerequisite_definition
  end

  subject { SSJ::Initialize.run(workflow_definition) }

  describe "#run" do
    it "should create a workflow instance and copy the processes/steps" do
      expect(subject).to be_a(Workflow::Instance::Workflow)

      process_instance = subject.processes.where(definition_id: process_definition.id).first
      prerequisite_instance = subject.processes.where(definition_id: prerequisite_definition.id).first

      slice = [:title, :description, :position, :category_list, :phase_list]
      expect(process_instance.attributes.with_indifferent_access.slice(*slice)).to eq(process_definition.attributes.with_indifferent_access.slice(*slice))
      expect(prerequisite_instance.attributes.with_indifferent_access.slice(*slice)).to eq(prerequisite_definition.attributes.with_indifferent_access.slice(*slice))
      expect(process_instance.title).to be_present
      expect(prerequisite_instance.title).to be_present
      
      step1 = process_instance.steps.first
      step2 = prerequisite_instance.steps.first

      slice = [:title, :description, :kind, :completion_type, :min_worktime, :max_worktime, :decision_question, :position]
      expect(step1.attributes.with_indifferent_access.slice(*slice)).to eq(step_definition.attributes.with_indifferent_access.slice(*slice))
      expect(step2.attributes.with_indifferent_access.slice(*slice)).to eq(step2_definition.attributes.with_indifferent_access.slice(*slice))
      expect(step1.title).to be_present
      expect(step2.title).to be_present

      dependency_instance = subject.dependencies.first
      expect(dependency_instance.workable).to eq(process_instance)
      expect(dependency_instance.prerequisite_workable).to eq(prerequisite_instance)

      expect(process_instance).to_not be_prerequisites_met
      expect(prerequisite_instance).to be_prerequisites_met
    end
  end
end