class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :position, :completed_at, :description

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

  attribute :min_worktime do |step|
    step.definition&.min_worktime
  end

  attribute :max_worktime do |step|
    step.definition&.max_worktime
  end

  # bit of a hack so we can have assignee information when the step serializer is nested in the process serializer
  attribute :assignee_info do |step, params|
    if assignee = !params[:basic] && step.assignee
      { id: assignee.external_identifier, imageUrl: assignee.image_url }
    end
  end
end
