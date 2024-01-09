namespace :network do
  desc 'Seed schools'
  task seed: [:environment, "network:partner"] do
    # create schools and people connected to schools.

    image_rotation = [
      'https://en.gravatar.com/userimage/4310496/6924cffc6c2e516293c1e8b6e7533ab5.jpg',
      'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
      'https://ca.slack-edge.com/T1BCRBEKF-U044095NSKW-gb71eb8af435-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U6YFWTW67-8c867b8d8fff-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U0431E2ANE6-a196fd3638aa-512',
      'https://ca.slack-edge.com/T1BCRBEKF-UC1RV1LQ5-eb11f16c81c0-192',
    ]

    25.times do |i|
      print "."
      person1 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
      person2 = FactoryBot.create(:person, image_url: image_rotation[i%image_rotation.length])
    
      user1 = FactoryBot.create(:user, :person => person1, email: "network#{(i)*2+1}@test.com", password: "password")
      user2 = FactoryBot.create(:user, :person => person2, email: "network#{(i+1)*2}@test.com", password: "password")

      school = FactoryBot.create(:school, name: "School #{i+1}")
      # connect school and people
    end
  end

  desc "Seed WF partners"
  task partner: [:environment] do
    # augment with airtable data.
    [
      ["katie.brand@wildflowerschools.org", "Katie Brand", "https://ca.slack-edge.com/T1BCRBEKF-U04N46WR64E-f5a5bf76cf74-512"],
      ["pooja.pandit@wildflowerschools.org", "Pooja Pandit"],
      ["iris.chen@wildflowerschools.org", "Iris Chen"],
      ["lindsey.barnes@wildflowerschools.org", "Lindsey Barnes"],
      ["isabelle.parker@wildflowerschools.org", "Isabelle Parker"],
      ["maia.blankenship@wildflowerschools.org", "Maia Blankenship"],
      ["erica.cantoni@wildflowerschools.org", "Erica Cantoni"],
      ["koren.clark@wildflowerschools.org", "Koren Clark"],
      ["amy.gips@wildflowerschools.org", "Amy Gips"],
      ["sunny.greenberg@wildflowerschools.org", "Sunny Greenberg"],
      ["ben.talberg@wildflowerschools.org", "Ben Talberg"],
      ["rachel.kelley-cohn@wildflowerschools.org", "Rachel Kelley-Cohn"],
      ["matthew.kramer@wildflowerschools.org", "Matthew Kramer"],
      ["cam.leonard@wildflowerschools.org", "Cam Leonard"],
      ["erika.mcdowell@wildflowerschools.org", "Erika McDowell"],
      ["maggie.paulin@wildflowerschools.org", "Maggie Paulin"],
      ["alia.peera@wildflowerschools.org" , "Alia Peera"],
      ["ted.quinn@wildflowerschools.org", "Ted Quinn"],
      ["brandon.royce-diop@wildflowerschools.org", "Brandon Royce-Diop"],
      ["ali.scholes@wildflowerschools.org", "Ali Scholes"],
      ["kameeka.shirley@wildflowerschools.org", "Kameeka Shirley"],
      ["katelyn.shore@wildflowerschools.org", "Katelyn Shore"],
      ["jenny.tak@wildflowerschools.org", "Jenny Tak"],
      ["daniela.vasan@wildflowerschools.org", "Daniela Vasan"],
      ["maya.soriano@wildflowerschools.org", "Maya Soriano"],
      ["sara.hernandez@wildflowerschools.org", "Sara Hernandez"],
    ].each do |email, name, image_url|
      print "."
      person = Person.create!(:person, first_name: name.split(" ").first, last_name: name.split(" ").last, image_url: image_url)
      user = FactoryBot.create(:user, :person => person, email: email, password: "password")
      school = FactoryBot.create(:school, name: "Wildflower #{name}")
    end
  end

  desc "Mark onboarded people"
  task onboarded: [:environment] do
    emails = [
      'rachel.kimboko@dcwildflowerpcs.org', 
      'brandon.royce-diop@wildflowerschools.org', 
      'latania@blazingstarsmontessori.org', 
      'alejandra@thedahliaschoolsf.org', 
      'maggie@wildflowerschools.org',
      'katelyn.shore@wildflowerschools.org',
      'mary@wildflowermontessorischool.org'
    ]
    emails.each do |email|
      person = Person.find_by(email: email)
      person&.update!(is_onboarded: true)
    end
  end

  desc "Parse raw address"
  task address: [:environment] do
    School.all.each do |school|
      unless school.raw_address.nil?
        parse_addressable(school)
        print "."
      end
    end
  
    Person.all.each do |person|
      unless person.raw_address.nil?
        parse_addressable(person)
        print "."
      end
    end
  end

  desc "Sync Airtable with platform data"
  task sync_airtable: [:environment] do
    Network::UpdateAirtableRecords.call
  end

  desc "Send reminder to TL's to login to network"
  task send_remind_login: [:environment] do
    users_emailed = 0
    unsuccessful_emails = []
    User.all.each do |user|
      begin
        next unless person = user.person
        if person.active? && person.role_list.include?(Person::TL)
          NetworkMailer.remind_login(user)
          users_emailed += 1
        end
      rescue => e
        puts e.message
        puts "error sending remind_login to user #{user.email}"
        unsuccessful_emails << user.email
      end
    end
    puts "#{users_emailed} emails sent out"
    puts "Unable to send emails to #{unsuccessful_emails}" unless unsuccessful_emails.empty?
  end
end

def parse_addressable(addressable)
  if addressable.address.nil?
    parsed_address = Indirizzo::Address.new(addressable.raw_address.gsub("\n", ", "))
    address_lines = addressable.raw_address.split("\n")
    line2 =  address_lines.length > 3 ? address_lines[1] : nil

    Address.create!(
      addressable: addressable,
      line1: address_lines.first,
      line2: line2,
      zip: parsed_address.zip,
      city: parsed_address.city.first.titleize,
      state: parsed_address.state,
      country: parsed_address.country,
    )
    addressable.save!
  end
end