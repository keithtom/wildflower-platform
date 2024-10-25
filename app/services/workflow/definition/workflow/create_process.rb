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
          @process
        end

        def validate_workflow_and_params
          if @workflow.published?
            raise CreateProcessError,
                  'Cannot add processes to a published workflow. Please create a new version to continue.'
          end

          if @process_params[:recurring]
            raise CreateProcessError, 'Must create recurring process with duration' unless @process_params[:duration]
            unless @process_params[:due_months]
              raise CreateProcessError, 'Must create recurring process with due_months'
            end

            @process_params[:selected_processes_attributes] = [{}]
          end

          if @process_params[:selected_processes_attributes].nil?
            raise CreateProcessError, 'Must create process with selected_processes_attributes'
          end

          @process_params[:selected_processes_attributes].each do |sp_attr|
            sp_attr[:workflow_id] ||= @workflow.id
            unless sp_attr[:position] || @process_params[:recurring]
              raise CreateProcessError, 'Missing position in selected_processes_attributes'
            end
          end
        end

        def create_process
          @process = ::Workflow::Definition::Process.create!(@process_params.merge!(version: 'v1'))
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
