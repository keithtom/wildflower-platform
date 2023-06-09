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
end
