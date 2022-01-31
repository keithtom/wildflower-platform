# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'factory_bot_rails'
#
# ['Massachusetts',
# 'Minnesota',
# 'Puerto Rico',
# 'New York',
# 'New Jersey',
# 'Pennsylvania',
# 'Washington, D.C.',
# 'North Carolina',
# 'Northern California',
# 'Colorado',
# 'Emerging'].each do |hub_name|
#   Hub.create!(name: hub_name, :entrepreneur => FactoryBot.create(:person))
# end

hub1 = FactoryBot.create(:hub)
hub2 = FactoryBot.create(:hub)

pod1 = FactoryBot.create(:pod, hub: hub1)

school1 = FactoryBot.create(:school, :pod => pod1)
school2 = FactoryBot.create(:school)

person1 = FactoryBot.create(:person)
person2 = FactoryBot.create(:person)

user1 = FactoryBot.create(:user, :person => person1)
user2 = FactoryBot.create(:user, :person => person2)
user3 = FactoryBot.create(:user)  # hasn't yet associated person

school1.address = FactoryBot.create(:address)
school2.address = FactoryBot.create(:address)

person1.skills << FactoryBot.create(:skill)
person1.skills << FactoryBot.create(:skill)
person1.roles << FactoryBot.create(:role)
person1.address = FactoryBot.create(:address)
person1.experiences << FactoryBot.create(:person_experience, school: school1)


person2.skills << FactoryBot.create(:skill)
person2.roles << FactoryBot.create(:role)
