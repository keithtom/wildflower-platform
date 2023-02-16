require 'rails_helper'

class CategorizableFakeSerializer
  include V1::Categorizable
end

RSpec.describe V1::Categorizable, type: :concern do
  let(:process) { create(:workflow_instance_process) }

  describe "when the process is an instance and does not have its own categories" do
    it "fetches categories from the definition" do
      expect(process.category_list).to be_empty
      process.definition.category_list.add("Finance")
      process.definition.save!
      expect(CategorizableFakeSerializer.get_categories(process)).to_not be_empty
    end
  end

  describe "when the instance process and its definition have different categories" do
    let(:process_definition) { process.definition }
    let(:instance_category) { "Governance & Compliance" }
    let(:definition_category) { "Finance" }

    before do
      process.category_list.add(instance_category)
      process.save!
      process_definition.category_list.add(definition_category)
      process_definition.save!
    end

    describe "the instance process" do
      it "fetches categories from itself" do
        expect(CategorizableFakeSerializer.get_categories(process.reload)).to include(instance_category)
        expect(CategorizableFakeSerializer.get_categories(process.reload)).to_not include(definition_category)
      end
    end

    describe "the process is a definition" do
      it "fetches categories from itself" do
        expect(CategorizableFakeSerializer.get_categories(process_definition.reload)).to_not include(instance_category)
        expect(CategorizableFakeSerializer.get_categories(process_definition.reload)).to include(definition_category)
      end
    end
  end
end
