module Workflow
  module Definition
    class Workflow
      # Add a process to workflow
      class AddProcess < BaseService
        def initialize(workflow, process, position)
          @workflow = workflow
          @process = process
          @position = position
        end

        def run
          validate_workflow_state
          validate_position
          validate_recurring_attributes
          create_association
        end

        private

        def validate_workflow_state
          if @workflow.published?
            raise AddProcessError.new('Cannot add processes to a published workflow. Please create a new version to continue.')
          end
        end

        def validate_position
          return if @process.recurring?
          raise AddProcessError.new('Cannot add process to a workflow without a position') if @position.nil?
        end

        def validate_recurring_attributes
          if @process.recurring?
            raise AddProcessError.new('Cannot add recurring process to workflow if duration is nil') if @process.duration.nil?
            raise AddProcessError.new('Cannot add recurring process to workflow if due_months is nil') if @process.due_months.nil?
          end
        end

        def create_association
          sp = ::Workflow::Definition::SelectedProcess.create!(workflow_id: @workflow.id, process_id: @process.id, position: @position)
          sp.add!
          return sp
        end
      end
      class AddProcessError < StandardError
      end
    end
  end
end
