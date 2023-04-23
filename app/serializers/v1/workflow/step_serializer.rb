class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :kind, :position, :description  # completed is for backend use purposes and means something different in the front-end

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

  attribute :decision_options, if: proc { |step| step.decision? } do |step|
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

  attribute :can_assign do |step|
    # can't be assigned if it is already completed
    !step.completed
  end

  attribute :can_complete do |step, params|
    case step.completion_type
    when Workflow::Definition::Step::EACH_PERSON
      # did this person complete it?
    when Workflow::Definition::Step::ONE_PER_GROUP
      # did anyone complete it?
      !step.completed
    else
      raise "Unknown completion type: #{step.completion_type}"
    end
  end
  
  # When do we use this on step?  it should be refactored here.
  # bit of a hack so we can have assignee information when the step serializer is nested in the process serializer
  # attribute :assignee_info, if: Proc.new {|step, params| !params[:basic] && step.assignee } do |step|
  #   assignee = step.assignee
  #   { id: assignee.external_identifier, imageUrl: assignee.image_url }
  # end
end
