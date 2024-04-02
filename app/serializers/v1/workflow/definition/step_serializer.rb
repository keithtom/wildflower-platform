class V1::Workflow::Definition::StepSerializer < ApplicationSerializer
  set_id :id

  attributes :title, :description, :kind, :position, :completion_type, :decision_question, :min_worktime, :max_worktime

  has_many :decision_options, serializer: V1::Workflow::DecisionOptionSerializer do |step|
    step.decision_options
  end

  has_many :documents, serializer: V1::DocumentSerializerAdmin do |step|
    step.documents
  end
end
