class V1::Workflow::WorkflowSerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  attributes :name, :description, :version

  has_many :processes, serializer: V1::Workflow::ProcessSerializer,
    id_method_name: :external_identifier do |workflow|
      workflow.processes
  end

  link { v1_workflow_workflow_path(:external_identifier) }
end
