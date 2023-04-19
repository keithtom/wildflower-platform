module Workflow
  class Definition::Process < ApplicationRecord
    DEFAULT_INCREMENT = 100
    
    CATEGORIES = [
      ALBUMS_ADVICE_AND_NETWORK_MEMBERSHIP = "Albums, Advice & Network Membership",
      FINANCE = "Finance",
      FACILITIES = "Facilities",
      GOVERNANCE_AND_COMPLIANCE = "Governance & Compliance",
      HUMAN_RESOURCES = "Human Resources",
      COMMUNITY_AND_FAMILY_ENGAGEMENT = "Community & Family Engagement",
      CLASSROOM_PROGRAM_AND_PRACTICES = "Classroom Program & Practices"
    ]

    has_many :instances, class_name: 'Workflow::Instance::Process', foreign_key: 'definition_id'

    has_many :steps

    has_many :selected_processes
    has_many :workflows, through: :selected_processes

    acts_as_taggable_on :categories, :phase
    enum effort: { small: 0, medium: 1, large: 2 }

    scope :by_position, -> { order("workflow_instance_processes.position ASC") }
  end
end
