namespace :search do
  desc 'Re-index objects for search'

  task reindex: :environment do
    Person.reindex
    School.reindex
  end
end
