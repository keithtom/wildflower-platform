module Workflow
  class Create
    def self.call(definition_id:, school_id:)
      new(definition_id:, school_id:).call
    end

    def initialize(definition_id:, school_id:)
      @definition_id = definition_id
      @school_id = school_id
    end

    def call
      ActiveRecord::Base.transaction do
        find_resources
        create_workflow
      end
      schedule_background_jobs
      workflow
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Failed to create workflow: #{e.message}")
      raise ServiceError.new('School or workflow definition not found', :not_found)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create workflow: #{e.message}")
      raise ServiceError.new(e.message, :unprocessable_entity)
    rescue StandardError => e
      Rails.logger.error("Unexpected error creating workflow: #{e.message}")
      raise ServiceError.new('An unexpected error occurred', :internal_server_error)
    end

    private

    attr_reader :definition_id, :school_id, :workflow, :school, :definition

    def find_resources
      @definition = Workflow::Definition::Workflow.find(definition_id)
      @school = School.find_by!(external_identifier: school_id)
    end

    def create_workflow
      @workflow = Workflow::Instance::Workflow.create!(
        definition:,
        school:
      )
    end

    def schedule_background_jobs
      Workflow::InitializeWorkflowJob.perform_later(workflow.id)
      SchoolMailer.notify_partners_new_workflow(school.id).deliver_later
    end
  end

  class ServiceError < StandardError
    attr_reader :status

    def initialize(message, status)
      super(message)
      @status = status
    end
  end
end
