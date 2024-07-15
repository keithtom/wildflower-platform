require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::CreateProcess do
  describe '#run' do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:process_params) { 
      { 
        title: 'Updated Process', 
        description: 'This is an updated process', 
        category_list: "Finance", 
        phase_list: "Visioning",
        selected_processes_attributes: [{workflow_id: workflow.id, position: 109}]} 
      }
    let(:subject) { Workflow::Definition::Workflow::CreateProcess.new(workflow, process_params) }

    context "workflow is published" do
      let(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }

      it "raises an error" do
        expect { subject.run }.to raise_error(Workflow::Definition::Workflow::CreateProcessError)
      end
    end

    context 'position was not included' do
      context 'with non recurring process' do
        let(:process_params) { 
            {
              title: 'Updated Process',
              description: 'This is an updated process',
              category_list: 'Finance',
              phase_list: 'Visioning',
              selected_processes_attributes: [{ workflow_id: workflow.id }]
            }
          }

        it 'raises an error' do
          expect { subject.run }.to raise_error(Workflow::Definition::Workflow::CreateProcessError)
        end
      end

      context 'with recurring process' do
        let(:process_params) { 
            {
              title: 'Updated Process',
              description: 'This is an updated process',
              category_list: 'Finance',
              phase_list: 'Visioning',
              recurring: true,
              duration: 1,
              due_months: [5]
            }
          }

        it 'creates a process associated to the workflow' do
          expect { subject.run }.to change {Workflow::Definition::SelectedProcess.count}.by(1)
        end
      end
    end

    context "happy path" do
      context 'with non recurring process' do
        it "only creates one new selected process" do
          expect { subject.run }.to change {Workflow::Definition::SelectedProcess.count}.by(1)
        end

        it "creates a selected process in the state: added" do
          process = subject.run
          selected_process = Workflow::Definition::SelectedProcess.find_by(workflow_id: workflow.id, process_id: process.id)
          expect(selected_process.added?).to be true
        end
      
        it "creates a new process, setting the version to 1" do
          process = subject.run
          expect(process.version).to eq("v1")
        end
      end
    
      context 'with recurring process' do
      let(:process_params) { 
        { 
          title: 'Updated Process', 
          description: 'This is an updated process', 
          category_list: "Finance", 
          phase_list: "Visioning",
          recurring: true,
          duration: 1,
          due_months: [5]
        }}

        it "only creates one new selected process" do
          expect { subject.run }.to change {Workflow::Definition::SelectedProcess.count}.by(1)
        end

        it "creates a selected process in the state: added" do
          process = subject.run
          selected_process = Workflow::Definition::SelectedProcess.find_by(workflow_id: workflow.id, process_id: process.id)
          expect(selected_process.added?).to be true
        end
      
        it "creates a new process, setting the version to 1" do
          process = subject.run
          expect(process.version).to eq("v1")
        end
      end
    end
  end
end
