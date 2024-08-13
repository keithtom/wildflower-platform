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

  attribute :min_worktime do |step|
    distance_of_time_in_words(step.definition.min_worktime.minutes).capitalize if step.definition&.min_worktime
  end

  attribute :max_worktime do |step|
    distance_of_time_in_words(step.definition.max_worktime.minutes).capitalize if step.definition&.max_worktime
  end

  attribute :is_decision do |resource|
    resource.decision?
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

  attribute :is_assigned_to_me do |step, params|
    step.assigned_to?(params[:current_user].person) if params[:current_user]
  end

  attribute :can_assign do |step, params|
    if params[:current_user]
      person = params[:current_user].person
      !step.assigned_to?(person) && !step.completed_for?(params[:current_user].person)
    end
  end

  attribute :can_unassign do |step, params|
    step.assigned_to?(params[:current_user].person) if params[:current_user]
  end

  # this refers to if the current user should see the step as complete
  attribute :is_complete do |step, params|
    step.completed_for?(params[:current_user].person) if params[:current_user]
  end
  
  attribute :can_complete do |step, params|
    !step.completed_for?(params[:current_user].person) if params[:current_user]
  end

  # need messages of why it can't uncomplete.
  attribute :can_uncomplete do |step, params|
    # process can't be completed
    step.process.completed_at.blank? && params[:current_user] && step.completed_by_me?(params[:current_user].person)
  end
end
