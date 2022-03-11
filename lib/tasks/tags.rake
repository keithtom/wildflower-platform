namespace :tags do
  desc 'Setup the initial tags list.'
  task initialize: :environment do
    abort 'Tags already exist... aborting!' if ActsAsTaggableOn::Tag.any?

    # broad categories of people
    audience = ['charter', 'infant', 'toddler', 'primary', 'elementary', 'adolescent & high school', 'foundation',
                'regional site entrepreneur', 'operations guide', 'teacher leader']


    # roles are specific to *what* the people do
    # keep in mind roles can apply to TLs, hub partners and foundation
    general_roles = ['founder', 'board member', 'assistant teacher']

    tl_roles = ['finance', 'facilities', 'governance & compliance', 'human resources', 'community & family engagement', 'classroom & program practices']
    # sub roles, almost like topics within the role.
    # finance = budgeting, accounting, bookkeeping, loans, grants
    # facilities = lease, renovations, maintenance
    # governance & compliance = 501c3, board, policies, licensing, charter authorization, legal, compliance
    # human resources = hiring, payroll, benefits, staff policies, PD
    # community & family engagement = partnerships, marketing, admissions, enrollment, parent engagement, parent, communications

    # what are the roles by which OGs
    og_roles = ['regional fundraising']

    (tl_roles + audience).each do |name|
      ActsAsTaggableOn::Tag.create! name: name
    end
  end

  desc 'Create taggings for people and schools.'
  task build_tags: :enviroment do
    School.all.each do |school|
      # rake task to apply charter tag, then ages served tag to people and schools, everyone a TL, but then apply foundation and RSE/OG (maybe look at hola)
      if school.governance_type == School::Governance::CHARTER
        school.audience_list.add('charter')
      end
      school.ages_served.each do |age|
        tag = case age
          when 'adolescent', 'high school'
            'adolescent & high school'
          else
            age
          end
        school.audience_list.add(tag)
      end
      school.save!
    end

    People.include(:schools).all.each do |person|
      # for people who have/had teacher leader role
      audiences = person.schools.map(&:audience_list).flatten
      people.audience_list.add(*audiences)
      people.save!

      # for people who have/had RSE/OG role

      # for people who have/had foundation role
    end
    # school audience is easy
    # people audience is easy
    # people roles we need that data from TLs on how they split their work.
    # also how OGs self-tag their work?
    # if you have an OG role, you should be given the OG tags to opt into.

    # how do we find out who is board members of what school
    # how do we find out hte OGs vs RSE vs foudnation vs TL
  end
end
