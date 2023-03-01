class V1::Ssj::AssignedStepsSerializer < ApplicationSerializer
  def serializable_hash
    @resource.map do |assignee_id, steps|
      { assignee_info: assignee_info(steps), steps: serialized_steps(steps)}
    end
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
    steps.map do |step|
      V1::Workflow::StepSerializer.new(step, {params: {basic: true}, include: ['documents']})
    end
  end

  def assignee_info(steps)
    assignee = steps.first.assignee
    { id: assignee.external_identifier, imageUrl: assignee.image_url, email: assignee.email }
  end
end
