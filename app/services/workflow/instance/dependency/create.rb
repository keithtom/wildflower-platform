# frozen_string_literal: true

module Workflow
  module Instance
    class Dependency
      class Create < BaseService
        # this code assumes all workables are processes

        def initialize(dependency_definition, wf_instance, workable_process = nil, prereq_workable = nil)
          @dependency_definition = dependency_definition
          @wf_instance = wf_instance
          @workable_process = workable_process
          @prerequisite_workable = prereq_workable
          @dependency_instance = nil
        end

        def run
          find_prerequisite_workable if @prerequisite_workable.nil?
          find_workable_process if @workable_process.nil?
          create_dependency_instance
          return @dependency_instance
        end

        def find_prerequisite_workable
          prerequisite_process_ids = [@dependency_definition.prerequisite_workable_id]

          # during a rollout, it's possible the prerequisite was not updated because it was started.
          # therefore, use the original, unupdated prerequisite.
          if @dependency_definition.prerequisite_workable.previous_version
            prerequisite_process_ids << @dependency_definition.prerequisite_workable.previous_version_id
          end
          @prerequisite_workable = @wf_instance.processes.where(definition_id: prerequisite_process_ids).first

          if @prerequisite_workable.nil?
            Rails.logger.info("wf_instance_id: #{@wf_instance.id}")
            Rails.logger.info("dependecy definition_id: #{dependency_definition.id}")
            Rails.logger.info("prerequisite_process_ids: #{prerequisite_process_ids}")
            raise CreateError.new("prerequisite workable not found for dependency def #{@dependency_definition.id} and workflow instance id #{@wf_instance.id}")
          end
        end

        def find_workable_process
          workable_process_ids = [@dependency_definition.workable_id]

          # during a rollout, it's possible the workable was not updated because it was started.
          # therefore, use the original, unupdated workable.
          if @dependency_definition.workable.previous_version
            workable_process_ids << @dependency_definition.workable.previous_version_id
          end
          @workable_process = @wf_instance.processes.where(definition_id: workable_process_ids).first

          if @workable_process.nil?
            raise CreateError.new("workable not found for dependency def #{@dependency_definition.id} and workflow instance id #{@wf_instance.id}")
          end
        end

        def create_dependency_instance
          @dependency_instance = @dependency_definition.instances.create!(
            workflow: @wf_instance,
            workable: @workable_process,
            prerequisite_workable: @prerequisite_workable
          )
        end
      end
      class CreateError < StandardError
      end
    end
  end
end
