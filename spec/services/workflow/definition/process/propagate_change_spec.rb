require "rails_helper"

describe Workflow::Definition::Process::PropagateInstantaneousChange do
  describe "#run" do
    let(:process) { create(:workflow_definition_process) }
    let(:workflow) { Workflow::Definition::Workflow.create! }
    let!(:selected_process) { Workflow::Definition::SelectedProcess.create(workflow_id: workflow.id, process_id: process.id, position: 1)}
    let(:param_changes) { 
      {
        "title"=>"Updated Process",                                                                                                            
        "description"=>"This is an updated process",                                                                                           
        "category_list"=>["category 1", "category 2", "category 3"],                                                     
      }  
    }

    it "should permit valid attribute changes" do
      expect { described_class.run(process, param_changes) }.not_to raise_error
    end

    it "should raise an error for unpermitted attribute changes" do
      param_changes[:phase_list] = ["Visioning"]
      expect { described_class.run(process, param_changes) }.to raise_error(StandardError, "Attribute(s) cannot be an instantaneously changed: phase_list")
    end

    context 'when attribute is specifically for recurring process' do
      context 'for due months' do
        it "should raise an error for unpermitted attribute changes" do
          param_changes[:due_months] = [1, 2, 3]
          expect { described_class.run(process, param_changes) }.to raise_error(StandardError, "Attribute(s) cannot be an instantaneously changed: due_months")
        end
      end

      context 'for duration' do
        it "should raise an error for unpermitted attribute changes" do
          param_changes[:duration] = 12
          expect { described_class.run(process, param_changes) }.to raise_error(StandardError, "Attribute(s) cannot be an instantaneously changed: duration")
        end
      end

      context 'for recurring' do
        it "should raise an error for unpermitted attribute changes" do
          param_changes[:recurring] = true
          expect { described_class.run(process, param_changes) }.to raise_error(StandardError, "Attribute(s) cannot be an instantaneously changed: recurring")
        end
      end
    end

    it "should update definition" do
      described_class.run(process, param_changes)
      expect(process.category_list).to eq(param_changes["category_list"])
    end

    it "should update instances" do
      process_instance = create(:workflow_instance_process, definition: process, position: 1000, workflow: create(:workflow_instance_workflow, definition: workflow))
      expect(process_instance.title).to_not eq("Updated Process")

      described_class.run(process, param_changes)
    
      expect(process_instance.reload.title).to eq("Updated Process")
      expect(process_instance.category_list).to eq(param_changes["category_list"])
    end
  end
end