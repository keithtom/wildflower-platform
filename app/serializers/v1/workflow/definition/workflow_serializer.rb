# frozen_string_literal: true

class V1::Workflow::Definition::WorkflowSerializer < ApplicationSerializer
  set_id :id

  attributes :name, :description, :version, :created_at, :rollout_started_at, :rollout_completed_at,
             :previous_version_id, :needs_support, :recurring

  attribute :num_of_versions do |workflow|
    Workflow::Definition::Workflow.where(name: workflow.name).count
  end

  attribute :num_of_instances do |workflow|
    workflow.instances.count
  end

  attribute :published, &:published?

  attribute :rollout_in_progress do |workflow|
    !workflow.rollout_started_at.nil? && workflow.rollout_completed_at.nil?
  end

  has_many :processes, serializer: V1::Workflow::Definition::BasicProcessSerializer do |workflow, params|
    if params[:workflow_id]
      workflow.displayed_processes.includes(:taggings, :categories).order('workflow_definition_selected_processes.position')
    end
  end
end
