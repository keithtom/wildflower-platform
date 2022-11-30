require 'rails_helper'

RSpec.describe Workflow::Instance::Process, type: :model do
  let(:process) { create(:workflow_instance_process) }
  describe "when the instance does not have its own categories" do
    it "fetches categories from the definition" do
      expect(process.category_list).to be_empty
      process.definition.category_list.add("Finance")
      process.definition.save!
      expect(process.reload.category_list).to_not be_empty
    end
  end
end
