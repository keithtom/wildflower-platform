namespace :hubs do
  desc 'Create hardcoded hubs'

  task create: :environment do
    abort 'Hubs already exist... aborting!' if Hub.any?

    names = ["Colorado",
    "Emerging",
    "Massachusetts",
    "Minnesota",
    "New Jersey",
    "New York",
    "North Carolina",
    "Northern California",
    "Pennsylvania",
    "Puerto Rico",
    "Washington, D.C."]

    names.each do |name|
      Hub.create! :name => name
    end

    pods =
    [["Mass: Broadway", "Massachusetts"],
     ["Mass: Massbridge", "Massachusetts"],
     ["Mass: San Lorenzo", "Massachusetts"],
     ["Penn: Philadelphia", "Pennsylvania"]]


    pods.each do |row|
      hub = Hub.find_by!(name: row[1])
      Pod.create!(name: row[0], hub: hub)
    end


    # once people are added, associate to hub/pod.
  end
end
