module Workflow
  module Definition
    class Workflow
      class CreateDummy < BaseService
        def initialize(name)
          @name = name
        end
        
        def run
          workflow_definition = FactoryBot.create(:workflow_definition_workflow, name: @name, version: "v1", published_at: DateTime.now)

          # Visioning
          process1 = FactoryBot.create(:workflow_definition_process, title: "Milestone A", description: "A single milestone with 3 steps", version: "v1", published_at: DateTime.now)
          3.times { |i| FactoryBot.create(:workflow_definition_step, process: process1, title: "Step #{i+1}", description: "Step #{i+1} of 3") }
          
          process2 = FactoryBot.create(:workflow_definition_process, title: "Milestone B-1", description: "A sequential milestone: B-1 then B-2", version: "v1", published_at: DateTime.now)
          decision_step = FactoryBot.create(:workflow_definition_step, process: process2, title: "Decision Step 1", description: "A single decision step with 3 options", kind: ::Workflow::Definition::Step::DECISION, position: ::Workflow::Definition::Step::DEFAULT_INCREMENT)
          3.times { |i| FactoryBot.create(:workflow_decision_option, decision: decision_step, description: "Option #{i+1}") }
          
          process3 = FactoryBot.create(:workflow_definition_process, title: "Milestone B-2", description: "The second milestone B-2 should be worked on after B-1 is done.", version: "v1", published_at: DateTime.now)
          2.times { |i| FactoryBot.create(:workflow_definition_step, process: process3, title: "Step #{i+1}", description: "Step #{i+1} of 2") }
          
          [process1, process2, process3].each_with_index do |process, i|
            workflow_definition.processes << process
          
            process.phase_list = ::SSJ::Phase::VISIONING
            process.category_list = ::SSJ::Category::CATEGORIES[i]
            process.save!
          end
          workflow_definition.dependencies.create! workable: process3, prerequisite_workable: process2
          
          # Planning
          process4 = FactoryBot.create(:workflow_definition_process, title: "Milestone C", description: "A milestone that unlocks 2 other milestones: C-X and C-Y", version: "v1", published_at: DateTime.now)
          2.times { |i| FactoryBot.create(:workflow_definition_step, process: process4, title: "Step #{i+1}", description: "Step #{i+1} of 2") }
          
          process5 = FactoryBot.create(:workflow_definition_process, title: "Milestone C-X", description: "This milestone gets unlocked after C is done.", version: "v1", published_at: DateTime.now)
          decision_step = FactoryBot.create(:workflow_definition_step, process: process5, title: "Collaborative Decision Step 1", description: "A Collaborative Decision Step with 4 options", kind: ::Workflow::Definition::Step::DECISION, completion_type: ::Workflow::Definition::Step::ONE_PER_GROUP, position: ::Workflow::Definition::Step::DEFAULT_INCREMENT)
          4.times { |i| FactoryBot.create(:workflow_decision_option, decision: decision_step, description: "Option #{i+1}") }
          
          process6 = FactoryBot.create(:workflow_definition_process, title: "Milestone C-Y", description: "This milestone gets unlocked after C is done.", version: "v1", published_at: DateTime.now)
          2.times { |i| FactoryBot.create(:workflow_definition_step, process: process6, title: "Step #{i+1}", description: "Step #{i+1} of 2") }
          
          [process4, process5, process6].each_with_index do |process, i|
            workflow_definition.processes << process
          
            process.phase_list = ::SSJ::Phase::PLANNING
            process.category_list = ::SSJ::Category::CATEGORIES[i+3]
            process.save!
          end
          workflow_definition.dependencies.create! workable: process5, prerequisite_workable: process4
          workflow_definition.dependencies.create! workable: process6, prerequisite_workable: process4
          
          # Startup
          process7 = FactoryBot.create(:workflow_definition_process, title: "Milestone D", description: "A milestone that is 1 of 2 pre-requisites for Milestone D-E-F", version: "v1", published_at: DateTime.now)
          1.times { |i| FactoryBot.create(:workflow_definition_step, process: process7, title: "Step #{i+1}", description: "A single step") }
          
          process8 = FactoryBot.create(:workflow_definition_process, title: "Milestone E", description: "A milestone that is 1 of 2 pre-requisites for Milestone D-E-F", version: "v1", published_at: DateTime.now)
          1.times { |i| FactoryBot.create(:workflow_definition_step, process: process8, title: "Step #{i+1}", description: "A single step") }
          
          process9 = FactoryBot.create(:workflow_definition_process, title: "Milestone D-E-F", description: "Unlocked only when BOTH Milestone D & E are completed", version: "v1", published_at: DateTime.now)
          2.times { |i| FactoryBot.create(:workflow_definition_step, process: process9, title: "Collaborative Step #{i+1}", description: "Collaborative Step #{i+1} of 2", completion_type: ::Workflow::Definition::Step::ONE_PER_GROUP) }
          
          [process7, process8, process9].each_with_index do |process, i|
            workflow_definition.processes << process
          
            process.phase_list = ::SSJ::Phase::STARTUP
            process.category_list = ::SSJ::Category::CATEGORIES[i]
            process.save!
          end
          workflow_definition.dependencies.create! workable: process9, prerequisite_workable: process7
          workflow_definition.dependencies.create! workable: process9, prerequisite_workable: process8
        
          return workflow_definition
        end
      end
    end
  end
end