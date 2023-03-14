class V1::SSJ::AssignedStepsSerializer < ApplicationSerializer
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
    serializer: V1::PersonSerializer do |step|
    step.assignee
  end

  belongs_to :process, serializer: V1::Workflow::ProcessSerializer, record_type: :workflow_instance_process,
    id_method_name: :external_identifier do |step|
      step.process
  end


  private

  def serialized_steps(steps)
    steps.map do |step|
      V1::Workflow::StepSerializer.new(step, {params: {basic: true}, include: ['documents', 'process']})
    end
  end

  def assignee_info(steps)
    assignee = steps.first.assignee
    { id: assignee.external_identifier, imageUrl: assignee.image_url, email: assignee.email }
  end
end
