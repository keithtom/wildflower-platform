class V1::Workflow::StepAssignmentSerializer < ApplicationSerializer
  set_id :id # TODO: change to extenral identifier
  set_type :assignment

  attributes :completed_at
  attribute :assigned_at do |record|
    record.created_at
  end

  belongs_to :step, id_method_name: :external_identifier do |record|
    record.step
  end

  belongs_to :assignee, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |record|
    record.assignee
  end

  belongs_to :selected_option, if: proc { |resource| resource.step.decision? }, serializer: V1::Workflow::DecisionOptionSerializer, id_method_name: :external_identifier do |step|
    step.selected_option
  end
end