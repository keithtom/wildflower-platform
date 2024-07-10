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
          raise CreateProcessError.new('Cannot add processes to a published workflow. Please create a new version to continue.') if @workflow.published?

          if @process_params[:recurring]
            raise CreateProcessError.new('Must create recurring process with duration') unless @process_params[:duration]
            raise CreateProcessError.new('Must create recurring process with due_months') unless @process_params[:due_months]
            @process_params[:selected_processes_attributes] = [{}]
          end

          if @process_params[:selected_processes_attributes].nil?
            raise CreateProcessError.new('Must create process with selected_processes_attributes')
          end

          @process_params[:selected_processes_attributes].each do |sp_attr|
            sp_attr[:workflow_id] ||= @workflow.id
            raise CreateProcessError.new('Missing position in selected_processes_attributes') unless (sp_attr[:position] || @process_params[:recurring])
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
