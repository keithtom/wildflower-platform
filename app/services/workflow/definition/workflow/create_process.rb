# frozen_string_literal: true

module Workflow
  module Definition
    class Workflow
      # Add a process to workflow
      class CreateProcess < BaseService
        def initialize(workflow, process_params)
          @workflow = workflow
          @process_params = process_params.to_hash.with_indifferent_access
          @process = nil
        end

        def run
          validate_workflow_and_params
          create_process
          return @process
        end

        def validate_workflow_and_params
          if @workflow.published?
            raise CreateProcessError.new('Cannot add processes to a published workflow. Please create a new version to continue.')
          end

          if @process_params[:selected_processes_attributes].nil? && !@process_params[:recurring]
            raise CreateProcessError.new('Must create process with a position')
          end

          @process_params[:selected_processes_attributes].each do |sp_attr|
            if sp_attr[:workflow_id].nil?
              raise CreateProcessError.new('Missing workflow_id in selected_processes_attributes')
            end

            if sp_attr[:position].nil?
              raise CreateProcessError.new('Missing position in selected_processes_attributes')
            end
          end
        end

        def create_process
          @process = ::Workflow::Definition::Process.create!(@process_params.merge!(version: "v1"))
          @process.selected_processes.each do |sp|
            sp.add!
          end
        end
      end

      class CreateProcessError < StandardError
      end
    end
  end
end
