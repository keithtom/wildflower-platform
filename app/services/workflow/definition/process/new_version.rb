module Workflow
  module Definition
    class Process
      class NewVersion < BaseService
        def initialize(process, workflow)
          @process = process
          @workflow = workflow
          @new_version = nil
        end
      
        def run
          create_new_version
          clone_steps
          clone_dependencies
          return @new_version
        end
      
        private

        def create_new_version
          @new_version = @process.dup
          @new_version.previous_version_id = @process.id
          @new_version.version = "v#{@process.version[1..-1].to_i + 1}"
          @new_version.save!
        end
      
        # TODO: push this to a background worker?
        def clone_steps
          @process.steps.each do |step|
            new_step = step.dup
            new_step.process_id = @new_version.id
            new_step.save!
          
            step.documents.each do |document|
              new_document = document.dup
              new_document.documentable = new_step
              new_document.save!
            end
          
            step.decision_options.each do |decision_option|
              new_decision_option = decision_option.dup
              new_decision_option.decision = step
              new_decision_option.save!
            end
          end
        end
      
        def clone_dependencies
          process.workable_dependencies.each do |dependency|
            new_dependency = dependency.dup
            new_dependency.workable = @new_version
            new_dependency.save!
          end
        end
      end
    end
  end
end
