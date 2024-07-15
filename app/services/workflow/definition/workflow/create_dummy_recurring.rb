module Workflow
  module Definition
    class Workflow
      class CreateDummyRecurring < BaseService
        def initialize(name)
          @name = name
        end

        def run
          workflow_definition = FactoryBot.create(:workflow_definition_workflow, name: @name, version: "v1", published_at: DateTime.now, recurring: true)

          process1 = FactoryBot.create(:workflow_definition_process,
                                       title: "Milestone A - Recurs Monthly",
                                       description: 'A single milestone with 3 steps',
                                       version: 'v1',
                                       published_at: DateTime.now,
                                       recurring: true,
                                       due_months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                                       duration: 1)
          3.times { |i| FactoryBot.create(:workflow_definition_step, process: process1, title: "Step #{i+1}", description: "Step #{i+1} of 3") }

          process2 = FactoryBot.create(:workflow_definition_process,
                                       title: "Milestone B - Recurs Quarterly",
                                       description: 'A single milestone with 3 steps',
                                       version: 'v1',
                                       published_at: DateTime.now,
                                       recurring: true,
                                       due_months: [3, 6, 9, 12],
                                       duration: 3)
          decision_step = FactoryBot.create(:workflow_definition_step, process: process2, title: "Decision Step 1", description: "A single decision step with 3 options", kind: ::Workflow::Definition::Step::DECISION, position: ::Workflow::Definition::Step::DEFAULT_INCREMENT)
          3.times { |i| FactoryBot.create(:workflow_decision_option, decision: decision_step, description: "Option #{i+1}") }

          process3 = FactoryBot.create(:workflow_definition_process,
                                       title: "Milestone C - Recurs Annually",
                                       description: 'A single milestone with 3 steps',
                                       version: 'v1',
                                       published_at: DateTime.now,
                                       recurring: true,
                                       due_months: [12],
                                       duration: 12)
          2.times { |i| FactoryBot.create(:workflow_definition_step, process: process3, title: "Step #{i+1}", description: "Step #{i+1} of 2") }

          annual_process_on_specific_month = []
          12.times do |i|
            process = FactoryBot.create(:workflow_definition_process,
                                        title: "Milestone #{i} - Recurs Annually, on a specific month",
                                        description: 'A single milestone with 3 steps',
                                        version: 'v1',
                                        published_at: DateTime.now,
                                        recurring: true,
                                        due_months: [(i + 1)],
                                        duration: 1)
            annual_process_on_specific_month << process
            2.times { |i| FactoryBot.create(:workflow_definition_step, process: process, title: "Step #{i+1}", description: "Step #{i+1} of 2") }
          end

          process5 = FactoryBot.create(:workflow_definition_process,
                                       title: "Milestone E - Recurs Annually, Summertime",
                                       description: 'A single milestone with 3 steps',
                                       version: 'v1',
                                       published_at: DateTime.now,
                                       recurring: true,
                                       due_months: [8],
                                       duration: 2)
          2.times { |i| FactoryBot.create(:workflow_definition_step, process: process5, title: "Step #{i+1}", description: "Step #{i+1} of 2") }

          ([process1, process2, process3, process5] + annual_process_on_specific_month).each_with_index do |process, i|
            workflow_definition.processes << process

            process.category_list = ::SSJ::Category::CATEGORIES[i]
            process.save!
          end

          return workflow_definition
        end
      end
    end
  end
end