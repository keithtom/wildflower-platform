# frozen_string_literal: true

class SSJ::WorkflowInstance < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier
	belongs_to :workflow, class_name: 'Workflow::Instance::Workflow', foreign_key: 'workflow_instance_workflow_id'
	belongs_to :person
end
