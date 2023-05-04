namespace :staging do
  desc 'Seed initial users'
  task initialize: :environment do
    daniela = User.find_or_create_by!(email: "daniela.vasan@wildflowerschools.org") do |user|
      user.password = "password"
    end
    daniela_person = daniela.person || Person.create!(email: "daniela.vasan@wildflowerschools.org", first_name: "Daniela", last_name: "Vasan", image_url: "https://files.slack.com/files-pri/T1BCRBEKF-F056GR2P6L9/headshot2.jpg")

    sunny = User.find_or_create_by!(email: "sunny.greenberg@wildflowerschools.org") do |user|
      user.password = "password"
    end
    sunny_person = sunny.person || Person.create!(email: "sunny.greenberg@wildflowerschools.org", first_name: "Sunny", last_name: "Greenberg", image_url: "https://files.slack.com/files-pri/T1BCRBEKF-F0563MTR3L1/sunny_greenberg_mid-atlantic_region.jpeg")

    adassa = User.find_or_create_by!(email: "anedd28@gmail.com") do |user|
      user.password = "password"
    end
    adassa_person = adassa.person || Person.create!(email: "anedd28@gmail.com", first_name: "Adassa", last_name: "Brutus")
    adassa_person.gender = "Female"
    adassa_person.lgbtqia = false

    team = adasa.person.ssj_team || SSJ::Team.create!
    
    team.ops_guide = sunny
    team.regional_growth_lead = daniela
    team.ops_guides << sunny
    team.regional_growth_leads << daniela

    team.expected_start_date = Date.parse("1/1/2024")

    team.save!
  end
end
