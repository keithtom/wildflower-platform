namespace :tags do
  desc 'Setup the initial tags list.'
  task initialize: :environment do
    abort 'Tags already exist... aborting!' if ActsAsTaggableOn::Tag.any?

    roles = ['founder', 'board member', 'assistant teacher', 'operations', 'communications', 'finance', 'marketing',
             'admissions', 'compliance', 'fundraising', 'well-being']
    audience = ['charter', 'infant', 'toddler', 'primary', 'elementary', 'adolescent & high school', 'foundation',
                'regional site entrepreneur & operations guide', 'teacher leader']

    (roles + audience).each do |name|
      ActsAsTaggableOn::Tag.create! name: name
    end
  end
end
