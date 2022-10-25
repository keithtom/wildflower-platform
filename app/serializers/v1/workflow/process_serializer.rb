class ProcessSerializer
  include JSONAPI::Serializer

  attributes :title, :effort, :categories, :status, :position #, :assignee

  attribute :workflow do |object|
    WorkflowSerializer.new(object.workflow).serializable_hash
  end

  attribute :steps do |object|
    object.steps.map do |step|
      StepSerializer.new(step).serializable_hash
    end
  end
end

