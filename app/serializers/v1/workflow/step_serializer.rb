class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :position, :description

  belongs_to :process, serializer: V1::Workflow::ProcessSerializer,
    id_method_name: :external_identifier do |step|
      step.process
  end

  has_many :documents, serializer: V1::DocumentSerializer,
    id_method_name: :external_identifier do |step|
      step.documents
  end

  has_many :assignments,
    serializer: V1::Workflow::StepAssignmentSerializer do |step|
      step.assignments
  end

  attribute :decision_options do |step|
    unless step.definition.nil? || step.kind != Workflow::Definition::Step::DECISION
      step.definition.decision_options.map {|decision_option| V1::Workflow::DecisionOptionSerializer.new(decision_option).to_json }
    end
  end

  attribute :min_worktime do |step|
    distance_of_time_in_words(step.definition.min_worktime.minutes).capitalize if step.definition&.min_worktime
  end

  attribute :max_worktime do |step|
    distance_of_time_in_words(step.definition.max_worktime.minutes).capitalize if step.definition&.max_worktime
  end
end
