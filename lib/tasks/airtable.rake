namespace :airtable do
  desc "Set School Relationship name if there is none"
  task set_school_relationship_name: [:environment] do
    SchoolRelationship.where(name: nil).each do |sr|
      if sr.person && sr.school
        sr.name = "#{sr.person.name} - #{sr.school.name}"
        sr.save!
      end
    end
  end
end