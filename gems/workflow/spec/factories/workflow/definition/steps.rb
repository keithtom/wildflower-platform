FactoryBot.define do
  factory :definition_step, class: 'Definition::Step' do
    association :process, factory: :defition_process
    name { process.name.to_i + rand(1..99) }
    description "A number in this group.""

    weight { rand(1..20) * 5 }
  end
end
