namespace :schools do
  desc 'Update directory_visible to true for all affiliated schools'
  task update_directory_visibility: :environment do
    puts 'Updating directory_visible for affiliated schools...'

    total_schools = School.count
    affiliated_schools = School.where(affiliated: true)
    updated_count = 0

    affiliated_schools.find_each do |school|
      school.update_column(:directory_visible, true)
      updated_count += 1
    end

    puts "Done! Updated #{updated_count} out of #{total_schools} schools."
    puts 'Set directory_visible = true for all affiliated schools.'
  end
end
