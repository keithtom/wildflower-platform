class ProcessSerializer
  include JSONAPI::Serializer

  attributes :title, :effort, :categories, :status, :position #, :assignee

  attribute :workflow do |object|
    { name: object.workflow.name, description: object.workflow.description }
  end

  attribute :steps do |object|
    object.steps.map do |step|
      { title: step.title, completed: step.completed, kind: step.kind, resource_url: step.resource_url, position: step.position }
    end
  end
end

