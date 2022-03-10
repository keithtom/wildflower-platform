namespace :tags do
  desc 'Setup the initial tags list.'
  task 'initialize' do
    if ActsAsTaggableOn::Tag.any?
      puts 'Tags already exist... aborting!'
      return
    end

    roles = ['founder', 'board member', 'assistant teacher', 'operations', 'communications', 'finance', 'marketing',
             'admissions', 'compliance', 'fundraising', 'well-being']
    audience = ['charter', 'infant', 'toddler', 'primary', 'elementary', 'adolescent & high school', 'foundation',
                'regional site entrepreneur & operations guide', 'teacher leader']

    (roles + audience).each do |name|
      ActsAsTaggableOn::Tag.create name: name
    end
  end
end
