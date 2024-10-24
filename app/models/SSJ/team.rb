require "ssj"

module SSJ
  # Represents a team in the SSJ module.
  class Team < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    acts_as_paranoid
    audited

    # Associations
    belongs_to :ops_guide, class_name: 'Person', foreign_key: 'ops_guide_id', required: false
    belongs_to :regional_growth_lead, class_name: 'Person', foreign_key: 'regional_growth_lead_id', required: false
    has_many :team_members, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
    has_many :partner_members, -> { where(role: SSJ::TeamMember::PARTNER) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
    has_many :partners, through: :partner_members, source: :person do
      def active
        where('ssj_team_members.status = ?', SSJ::TeamMember::ACTIVE)
      end
    end
    has_many :ops_guide_members, -> { where(role: SSJ::TeamMember::OPS_GUIDE) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
    has_many :ops_guides, through: :ops_guide_members, source: :person
    has_many :rgl_members, -> { where(role: SSJ::TeamMember::RGL) }, class_name: "SSJ::TeamMember", foreign_key: 'ssj_team_id'
    has_many :rgls, through: :rgl_members, source: :person
    has_many :people, through: :team_members do
      def active
        where('ssj_team_members.status = ?', SSJ::TeamMember::ACTIVE)
      end
    end
    belongs_to :workflow, class_name: "Workflow::Instance::Workflow"
  
    def temp_location
      location = nil
      partner_members.includes([person: [:address]]).each do |member|
        location = location || member.person&.address&.state
      end

      return location
    end
  
    # Returns a temporary name for the team based on its partner members' first names, location, and level.
    def build_temp_name
      temp_name = ""
      location = nil
      level = []

      partner_members.includes(person: [:address, :taggings]).each do |member|
        unless member.person.first_name.nil?
          unless temp_name.empty?
            temp_name << "-"
          end
          temp_name << member.person.first_name
        end

        location = location || member.person&.address&.state
        level += member.person&.classroom_age_list
      end
      
      unless location.nil?
        temp_name << "-" + location
      end
      
      unless level.empty?
        temp_name << "-" + level.join("-")
      end
      
      unless temp_name.empty?
        temp_name << "-"
      end
      temp_name << "school"
      temp_name
    end
  end
end