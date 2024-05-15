require 'rails_helper'

RSpec.describe V1::Workflow::Definition::BasicProcessSerializer, type: :serializer do
  let(:process) { create(:workflow_definition_process) }
  let(:serializer) { described_class.new(process, { include: ['selected_processes'], params: { workflow_id: workflow.id } }) }
  let(:serialization) { serializer.as_json }
  let(:finance_category) { "Finance" }
  let(:phase) { "Visioning" }
  let(:workflow) { create(:workflow_definition_workflow) }
  let!(:selected_process) { Workflow::Definition::SelectedProcess.create(workflow_id: workflow.id, process_id: process.id) }

  before do
    process.category_list.add(finance_category)
    process.phase_list.add(phase)
    process.save!
  end

  describe 'serialization' do
    it 'includes the correct attributes' do
      expect(serialization["data"]["id"]).to eq(process.id.to_s)
      expect(serialization["data"]["attributes"]["title"]).to eq(process.title)
      expect(serialization["data"]["attributes"]["version"]).to eq(process.version)
      expect(serialization["data"]["attributes"]["phase"]).to eq(process.phase_list.first)
      expect(serialization["data"]["attributes"]["numOfSteps"]).to eq(process.steps.count)
      expect(serialization["data"]["attributes"]["categories"]).to eq([finance_category])
    end

    it 'includes the selected processes' do
      expect(serialization["included"]).to be_an(Array)
      expect(serialization["included"].count).to eq(process.selected_processes.count)
      expect(serialization["included"].first).to eq(V1::Workflow::Definition::SelectedProcessSerializer.new(process.selected_processes.first).as_json["data"])
    end
  end
end