class V1::Workflow::StepSerializer < ApplicationSerializer
  attributes :title, :completed, :kind, :resource_url, :resource_title, :position
end
