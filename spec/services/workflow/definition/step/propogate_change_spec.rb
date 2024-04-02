require "rails_helper"

describe Workflow::Definition::Step::PropogateChange do
  describe "#validate_param_changes" do
    let(:step) { create(:workflow_definition_step) }
    let(:param_changes) { 
      {
        "title"=>"Updated Step",                                                                                                            
        "description"=>"This is an updated step",                                                                                           
        "position"=>2,                                                     
        "completion_type"=>"one_per_group",                                
        "decision_question"=>"Are you sure?",                              
        "documents_attributes"=>[{"title"=>"basic resource", "link"=>"www.example.com"}] # adding a document, what about updating one?
      }  
    }

    it "should permit valid attribute changes" do
      subject = described_class.new(step, param_changes)
      expect { subject.run }.not_to raise_error
    end

    it "should raise an error for unpermitted attribute changes" do
      param_changes[:kind] = "decision"
      subject = described_class.new(step, param_changes)
      expect { subject.run }.to raise_error(StandardError, "Attribute(s) cannot be an instantaneously changed: kind")
    end

    it "should raise an error for unpermitted attribute changes" do
      step_instance = create(:workflow_instance_step, definition: step)
      expect(step_instance.title).to_not eq("Updated Step")

      subject = described_class.new(step, param_changes)
      subject.run
    
      expect(step_instance.reload.title).to eq("Updated Step")
    end
  end
end