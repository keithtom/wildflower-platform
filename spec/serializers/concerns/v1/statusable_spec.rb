require 'rails_helper'

class StatusableFakeSerializer
  include V1::Statusable
end

RSpec.describe V1::Statusable, type: :concern do
  let(:workflow_definition) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let(:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }

  let(:prerequisite_definition) { Workflow::Definition::Process.create!(title: "prepare taxes", description: "gather tax worksheets", effort: 2) }
  let(:prerequisite) { Workflow::Instance::Process.create!(definition: prerequisite_definition, workflow: workflow) }
  let(:dependency_definition) { Workflow::Definition::Dependency.create!(workflow: workflow_definition, workable: process_definition, prerequisite_workable: prerequisite_definition) }
  let!(:dependency) { Workflow::Instance::Dependency.create!(workflow: workflow, workable: process, prerequisite_workable: prerequisite, definition: dependency_definition) }

  let(:person) { create(:person) }

  before do
    3.times do
      process.steps.create!
    end
  end

  context "steps unstarted" do
    before do
      prerequisite.steps.create!
    end

    context "prerequisites unmet" do
      it "has 'up next' status" do
        process.steps.each do |step|
          expect(step.completed).to be_falsey
        end

        expect(process.prerequisites.count).to_not eq(0)
        process.prerequisites.each do |prereq|
          expect(StatusableFakeSerializer.process_status(prereq)).to eq(V1::Statusable::TO_DO)
        end

        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::UP_NEXT)
      end
    end

    context "all prerequisites met" do
      before do
        process.prerequisites.each do |prereq|
          # previously, the steps would have callbacks to trigger completion of prereq.
          # a process should cache its status, or the matrix that i made before.
          # here we are just testing the mechanics of step completion.
          prereq.steps.each do |step|
            Workflow::Instance::Step::Complete.run(step, person)
          end
        end
      end

      it "has 'to do' status" do
        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)
      end
    end
  end

  context "1 of 3 steps completed" do
    before do
      prerequisite.steps.create!
      prerequisite.steps.create!

      step = process.steps.first
      Workflow::Instance::Step::Complete.run(step, person)
    end

    context "prerequisites unmet" do
      context "has incomplete steps that are assigned" do
        before do
          # assign incomplete step
          step = process.steps.incomplete.first
          step.assignments.create!(assignee_id: person.id)
        end

        it "has 'in progress' status" do
          expect(process.prerequisites.count).to_not eq(0)
          process.prerequisites.each do |prereq|
            expect(StatusableFakeSerializer.process_status(prereq)).to eq(V1::Statusable::TO_DO)
          end

          expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::IN_PROGRESS)
        end
      end

      it "has 'to do' status" do
        expect(process.prerequisites.count).to_not eq(0)
        process.prerequisites.each do |prereq|
          expect(StatusableFakeSerializer.process_status(prereq)).to eq(V1::Statusable::TO_DO)
        end

        expect(StatusableFakeSerializer.process_status(process.reload)).to eq(V1::Statusable::TO_DO)
      end
    end

    context "all prerequisites met" do
      before do
        process.prerequisites.each do |prereq|
          prereq.steps.each do |step|
            Workflow::Instance::Step::Complete.run(step, person)
          end
        end
      end

      it "has 'to do' status" do
        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)
      end
    end
  end

  context "3 of 3 steps completed" do
    before do
      prerequisite.steps.create!

      process.steps.each do |step|
        Workflow::Instance::Step::Complete.run(step, person)
      end
    end

    context "prerequisites unmet" do
      it "has 'done' status" do
        expect(process.prerequisites.count).to_not eq(0)
        process.prerequisites.each do |prereq|
          expect(StatusableFakeSerializer.process_status(prereq)).to eq(V1::Statusable::TO_DO)
        end

        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::DONE)
      end
    end

    context "all prerequisites met" do
      before do
        process.prerequisites.each do |prereq|
          prereq.steps.each do |step|
            Workflow::Instance::Step::Complete.run(step, person)
          end
        end
      end

      it "has 'done' status" do
        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::DONE)
      end
    end
  end
end
