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

# general context
hub1 = FactoryBot.create(:hub)
hub2 = FactoryBot.create(:hub)

pod1 = FactoryBot.create(:pod, hub: hub1)
school1 = FactoryBot.create(:school, :pod => pod1)
school1.address = FactoryBot.create(:address)

# two teacher leaders for school 1
person1 = FactoryBot.create(:person)
person2 = FactoryBot.create(:person)

user1 = FactoryBot.create(:user, :person => person1, email: "test@test.com", password: "password")
user2 = FactoryBot.create(:user, :person => person2, email: "test2@test.com", password: "password")

person1.role_list = "marketing, operations, teacher leader"
person1.address = FactoryBot.create(:address)
person1.school_relationships << FactoryBot.create(:school_relationship, school: school1)
person1.save!

person2.role_list = "compliance, communications, finance, teacher leader"
person2.address = FactoryBot.create(:address)
person2.school_relationships << FactoryBot.create(:school_relationship, school: school1)
person2.save!

# new ETL
person3 = FactoryBot.create(:person)
user3 = FactoryBot.create(:user, :person => person3)
pod3 = FactoryBot.create(:pod, hub: hub2)
school3 = FactoryBot.create(:school)
school3.address = FactoryBot.create(:address)

# ops guide
ops_guide = FactoryBot.create(:person)

# new discovery user
user3 = FactoryBot.create(:user)  # hasn't yet associated personal profile yet
