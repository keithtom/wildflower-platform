class Person
  # Logic related to operations guide role.
  # A person can hold many roles.
  module OperationsGuide
    extend ActiveSupport::Concern # https://dev.to/software_writer/how-rails-concerns-work-and-how-to-use-them-gi6

    included do
      has_many :og_team_members, class_name: "SSJ::TeamMember", foreign_key: 'person_id'
      has_many :og_teams, through: :og_team_members, source: :ssj_team
    end
  end
end