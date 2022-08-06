FactoryBot.define do
  factory :definition_process, class: 'Definition::Process' do
    version 1
    name { "#{rand(1..9) * 100}s" }
    description "A hundreds group.""

    weight { rand(1..20) * 5 }
  end
end
