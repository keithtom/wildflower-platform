class V1::Workflow::StepAssignmentSerializer < ApplicationSerializer
  set_id :id # TODO: change to extenral identifier
  set_type :assignment

  attributes :completed_at
  attribute :assigned_at do |record|
    record.created_at
  end

  # belongs_to :step, id_method_name: :external_identifier do |record|
  #   record.step
  # end

  belongs_to :assignee, serializer: V1::PersonSerializer, id_method_name: :external_identifier do |record, _params|
    record.assignee
  end
end
