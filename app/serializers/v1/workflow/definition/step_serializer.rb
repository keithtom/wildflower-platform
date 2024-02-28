class V1::Workflow::Definition::StepSerializer < ApplicationSerializer
  set_id :id

  attributes :title, :description, :kind, :position, :completion_type, :decision_question

  belongs_to :process, serializer: V1::Workflow::Definition::ProcessSerializer do |step|
    step.process
  end
end
