class V1::Ssj::AssignedStepsSerializer < ApplicationSerializer
  def serializable_hash
    @resource.map do |assignee_id, steps|
      [assignee_id, serialized_steps(steps)]
    end.to_h
  end

  has_many :documents, serializer: V1::DocumentSerializer, record_type: :document,
    id_method_name: :external_identifier do |step|
      step.documents
  end

  belongs_to :assignee, record_type: :people, id_method_name: :external_identifier,
    serializer: V1::PersonSerializer do |process|
    process.assignee
  end

  private

  def serialized_steps(steps)
    steps.map do |process|
      V1::Workflow::StepSerializer.new(process, root: false, include: @includes)
    end
  end
end
