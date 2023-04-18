class Person
  # Person logic specifically related to SSJ
  module SSJ
    extend ActiveSupport::Concern # https://dev.to/software_writer/how-rails-concerns-work-and-how-to-use-them-gi6

    included do
      has_one :ssj_team_member, class_name: "SSJ::TeamMember", foreign_key: 'person_id'
      has_one :ssj_team, through: :ssj_team_member
    end
  end
end