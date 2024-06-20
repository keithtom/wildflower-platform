module Workflow
  module Instance
    class Process
      class Create < BaseService
        def initialize(process_definition, workflow_definition, wf_instance)
          @process_definition = process_definition
          @workflow_definition = workflow_definition
          @wf_instance = wf_instance
          @process_instance = nil
        end

        def run
          create_process_instance
          create_step_instances
          return @process_instance
        end

        def create_process_instance
          # puts "definition", process_definition.category_list, process_definition.phase_list
          attributes = @process_definition.attributes.with_indifferent_access.slice(:title, :description)
          # puts "attributes", attributes.as_json
          position = @process_definition.selected_processes.where(workflow_id: @workflow_definition.id).first.position
          attributes.merge!(workflow: @wf_instance, position: position)

          @process_definition.occurrences_in_a_year.times do
            @process_instance = @process_definition.instances.create!(attributes)
            @process_instance.category_list = @process_definition.category_list
            @process_instance.phase_list = @process_definition.phase_list
            @process_instance.save!
          end
          # puts "instance", process_instance.as_json
        end

        def create_step_instances
          @process_definition.steps.each do |step_definition|
            # copy over documents? that seems a bit much.
            attributes = step_definition.attributes.with_indifferent_access.slice(:title, :description, :kind, :completion_type, :min_worktime, :max_worktime, :decision_question, :position)
            attributes.merge!(process_id: @process_instance.id)
            step_definition.instances.create!(attributes)
          end
        end
      end
    end
  end
end
