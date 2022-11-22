require 'rails_helper'

RSpec.describe V1::Statusable, type: :concern do
  let(:person) { create(:person) }
  let (:workflow_definition) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let (:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }
  before do
  end

  context "steps unstarted" do
    context "all prerequisites met" do
      it "has todo status" do
        
      end
    end

    context "prerequisites unmet" do
      it "has up next status do" do
      end
   end
  end
end
