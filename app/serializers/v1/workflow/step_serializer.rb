class StepSerializer
  include JSONAPI::Serializer
  attributes :title, :completed, :kind, :resource_url, :resource_title, :position
end
