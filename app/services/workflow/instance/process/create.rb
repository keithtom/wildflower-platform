module Workflow
  module Instance
    class Process
      class Create < BaseService
        def initialize(process_definition, workflow_definition, wf_instance, for_publishing = false)
          @process_definition = process_definition
          @workflow_definition = workflow_definition
          @wf_instance = wf_instance
          @process_instances = []
          @for_publishing = for_publishing
          @calculator = OpenSchools::DateCalculator.new if @process_definition.recurring?
        end

        def run
          create_process_instance
          create_step_instances
          @process_instances
        end

        def create_process_instance
          # puts "definition", process_definition.category_list, process_definition.phase_list
          attributes = @process_definition.attributes.with_indifferent_access.slice(:title, :description)
          # puts "attributes", attributes.as_json
          position = @process_definition.selected_processes.where(workflow_id: @workflow_definition.id).first.position
          attributes.merge!(workflow: @wf_instance, position:)

          months = @process_definition.recurring? ? @process_definition.due_months : [nil]
          months.each do |month|
            unless month.nil?
              due_date = @calculator.due_date(month)
              if @for_publishing && (due_date <= Time.zone.today)
                next
              end # only create processes in the future for publishing
            end

            process_instance = @process_definition.instances.create!(attributes)
            process_instance.category_list = @process_definition.category_list
            process_instance.phase_list = @process_definition.phase_list

            if due_date
              process_instance.due_date = due_date
              process_instance.suggested_start_date = @calculator.suggested_start_date(process_instance.due_date,
                                                                                       @process_definition.duration)
              process_instance.recurring_type = @process_definition.recurring_type
            end

            process_instance.save!
            @process_instances << process_instance
          end
          # puts "instance", process_instance.as_json
        end

        def create_step_instances
          @process_instances.each do |process_instance|
            @process_definition.steps.each do |step_definition|
              # copy over documents? that seems a bit much.
              attributes = step_definition.attributes.with_indifferent_access.slice(:title, :description, :kind,
                                                                                    :completion_type, :min_worktime, :max_worktime, :decision_question, :position)
              attributes.merge!(process_id: process_instance.id)
              step_definition.instances.create!(attributes)
            end
          end
        end
      end
    end
  end
end
