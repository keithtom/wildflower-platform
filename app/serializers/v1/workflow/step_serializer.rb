class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :kind, :position, :description, :completion_type  # completed is for backend use purposes and means something different in the front-end

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

  attribute :is_decision do |resource|
    resource.decision?
  end

  attribute :is_assigned_to_me do |step, params|
    step.assignments.where(assignee: params[:current_user].person).exists?
  end

  # this refers to if the current user should see the step as complete
  attribute :is_complete do |step, params|
    case
    when step.individual?
      params[:current_user] && step.assignments.complete.where(assignee: params[:current_user].person).exists?
    when step.collaborative?
      step.assignments.complete.exists?
    else
      raise "Unknown completion type: #{step.completion_type}"
    end
  end

  attribute :decision_question, if: proc { |step| step.decision? } do |step|
    step.definition.decision_question
  end
  
  # we don't persist selection without completion.
  attribute :selected_option, if: proc { |step| step.decision? } do |step, params|
    case
    when step.individual?
      params[:current_user] && step.assignments.where(assignee: params[:current_user].person).first&.selected_option&.external_identifier
    when step.collaborative?
      # take the first selected option
      step.assignments.where.not(selected_option: nil).order("created_at ASC").first&.selected_option&.external_identifier
    else
      raise "Unknown completion type: #{step.completion_type}"
    end
  end

  has_many :decision_options, if: proc { |step| step.decision? }, serializer: V1::Workflow::DecisionOptionSerializer, id_method_name: :external_identifier do |step|
    step.definition.decision_options.order("created_at ASC")
  end

  attribute :min_worktime do |step|
    distance_of_time_in_words(step.definition.min_worktime.minutes).capitalize if step.definition&.min_worktime
  end

  attribute :max_worktime do |step|
    distance_of_time_in_words(step.definition.max_worktime.minutes).capitalize if step.definition&.max_worktime
  end

  attribute :can_assign do |step|
    # can't be assigned if it is already completed
    !step.completed # and not already assigned?
  end

  attribute :can_unassign do |step, params|
    step.assignments.where(assignee: params[:current_user].person).exists?
  end

  attribute :can_complete do |step, params|
    case step.completion_type
    when Workflow::Definition::Step::EACH_PERSON
      # making our responses depending on the current user who requested them?  makes the resource not very restful.
      # we'll have to pass around current user into our serializers.
      # if we have the resoure be dumb, then we have to put intelligence of comlpetion in the front end.
      # shoudl the front end decide rules like can_complete? errors will result in API errors when use tries to complete but cant.
      # serializers should contain presentation logic.  and i wnat dumb front ends.
      params[:current_user] && !step.assignments.complete.where(assignee: params[:current_user].person).exists?
    when Workflow::Definition::Step::ONE_PER_GROUP
      !step.completed
    else
      raise "Unknown completion type: #{step.completion_type}"
    end
  end

  # need messages of why it can't uncomplete.
  attribute :can_uncomplete do |step, params|
    step.process.completed_at.blank? && step.assignments.complete.where(assignee: params[:current_user].person).exists?
  end
end
