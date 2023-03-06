class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :position, :completed_at, :description

  belongs_to :process, serializer: V1::Workflow::ProcessSerializer,
    id_method_name: :external_identifier do |step|
      step.process
  end

  has_many :documents, serializer: V1::DocumentSerializer,
    id_method_name: :external_identifier do |step|
      step.documents
  end

  belongs_to :selected_option, serializer: V1::Workflow::DecisionOptionSerializer,
    id_method_name: :external_identifier do |step|
      step.selected_option
  end

  belongs_to :assignee, id_method_name: :external_identifier,
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
  attribute :assignee_info, if: Proc.new {|step, params| !params[:self_assigned] && !params[:basic] && step.assignee } do |step|
    assignee = step.assignee
    { id: assignee.external_identifier, imageUrl: assignee.image_url }
  end
end
