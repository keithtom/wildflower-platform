class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :position, :completed_at

  belongs_to :process, serializer: V1::Workflow::ProcessSerializer, record_type: :workflow_instance_process,
    id_method_name: :external_identifier do |step|
      step.process
  end

  has_many :documents, serializer: V1::DocumentSerializer, record_type: :document,
    id_method_name: :external_identifier do |step|
      step.documents
  end

  belongs_to :selected_option, serializer: V1::Workflow::DecisionOptionSerializer, record_type: :workflow_decision_option,
    id_method_name: :external_identifier do |step|
      step.selected_option
  end

  belongs_to :assignee, record_type: :people, id_method_name: :external_identifier,
    serializer: V1::PersonSerializer do |process|
    process.assignee
  end

  attribute :decision_options do |step|
    unless step.definition.nil? || step.kind != Workflow::Definition::Step::DECISION
      step.definition.decision_options.map {|decision_option| V1::Workflow::DecisionOptionSerializer.new(decision_option).to_json }
    end
  end

  # bit of a hack so we can have assignee information when the step serializer is nested in the process serializer
  attribute :assignee_info do |step|
    if assignee = step.assignee
      { id: assignee.id, image_url: assignee.image_url }
    end
  end
end
