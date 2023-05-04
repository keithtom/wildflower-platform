FactoryBot.define do
  factory :workflow_instance_dependency, class: 'Workflow::Instance::Dependency' do
    association :definition, factory: :workflow_definition_dependency
    association :workflow, factory: :workflow_instance_workflow
    association :workable, factory: :workflow_instance_process
    association :prerequisite_workable, factory: :workflow_instance_process
  end
end

