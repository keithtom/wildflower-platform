class Person
  # Person logic specifically related to SSJ
  module SSJ
    extend ActiveSupport::Concern # https://dev.to/software_writer/how-rails-concerns-work-and-how-to-use-them-gi6

    included do
      has_one :ssj_team_member, -> { active }, class_name: "SSJ::TeamMember", foreign_key: 'person_id'
      has_one :ssj_team, through: :ssj_team_member
      has_many :ssj_team_members, class_name: "SSJ::TeamMember", foreign_key: 'person_id'

      after_save :update_ssj_team_member_status, if: :saved_change_to_is_onboarded?
    end

    def update_ssj_team_member_status
      if is_onboarded
        ssj_team_members.invited.update(status: 'active')
      end
    end
  end
end