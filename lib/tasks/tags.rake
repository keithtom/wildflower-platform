namespace :tags do
  desc 'Setup the initial tags list.'
  task initialize: :environment do
    abort 'Tags already exist... aborting!' if ActsAsTaggableOn::Tag.any?

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

    (tl_roles).each do |name|
      ActsAsTaggableOn::Tag.create! name: name
    end
  end
end
