module Workflow
  class Instance::Process
    class ReorderSteps < BaseService
      class Error < StandardError
        def message
          "Manually created steps cannot be reordered"
        end
      end

      def initialize(step, after_position)
        @step = step
        @after_position = after_position.to_i
      end

      def run
        unless @step.is_manual?
          raise Error
        end

        new_position = nil
        previous_position = 0

        @step.process.steps.order(:position).each do |step|
          if step.position > @after_position
            new_position = (previous_position + step.position) / 2
            break
          end

          previous_position = step.position
        end

        if new_position.nil?
          new_position = previous_position + Workflow::Definition::Step::DEFAULT_INCREMENT
        end

        @step.position = new_position
        @step.save!
      end
    end
  end
end
