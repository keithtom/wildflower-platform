class WorkflowSerializer
  include JSONAPI::Serializer

  attributes :name, :description

  attribute :processes do |object|
    object.processes.map do |process|
      { title: process.title, effort: process.effort, status: process.status, categories: process.categories }
    end
  end

  link :url
end

 w ||= Workflow::Instance::Workflow.last
 WorkflowSerializer.new(w).serializable_hash
