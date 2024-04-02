require "rails_helper"

describe Workflow::Definition::Step::PropogateChange do
  describe "#validate_param_changes" do
    let(:param_changes) { 
      {
        "title"=>"Updated Step",                                                                                                            
        "description"=>"This is an updated step",                                                                                           
        "kind"=>"decision",                                                                                                                 
        "position"=>2,                                                     
        "completion_type"=>"one_per_group",                                
        "decision_question"=>"Are you sure?",                              
        "documents_attributes"=>[{"title"=>"basic resource", "link"=>"www.example.com"}]
      }  
    }

    let(:valid_attr_changes) { [:attr1, :attr2] }

    it "should permit valid attribute changes" do
      subject = described_class.new(param_changes)
      expect { subject.validate_param_changes }.not_to raise_error
    end

    it "should raise an error for unpermitted attribute changes" do
      param_changes[:attr3] = "value3"
      subject = described_class.new(param_changes)
      expect { subject.validate_param_changes }.to raise_error(StandardError, "Attribute(s) cannot be an instantaneously changed")
    end
  end
end