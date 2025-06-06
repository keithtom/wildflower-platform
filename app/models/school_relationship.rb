class SchoolRelationship < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_paranoid
  acts_as_taggable_on :roles # the roles held during the relationship [Founder, Teacher Leader, Emerging Teacher Leader, Classroom Staff, Fellow, Other]

  belongs_to :school, touch: true
  belongs_to :person, touch: true

  after_create :set_name
  before_destroy :remove_from_airtable
  after_save :add_role_to_person
  after_commit :reindex_models

  scope :active, -> { where.not(start_date: nil).where(end_date: nil) }
  scope :invited, -> { where(start_date: nil).where(end_date: nil) }
  scope :partners, -> { tagged_with([Person::TL, Person::ETL], any: true) }
  scope :board_members, -> { tagged_with(Person::BOARD_MEMBER) }

  private

  # https://github.com/ankane/searchkick#indexing
  def reindex_models
    school.reindex
    person.reindex
  end

  def set_name
    self.name = "#{person.name} - #{school.name}"
    save!
  end

  def remove_from_airtable
    if platform_airtable_id
      RemoveAirtableRecordJob.perform_later(platform_airtable_id,
                                            Airtable::Platform::SCHOOL_RELATIONSHIP)
    end
  end

  def add_role_to_person
    return if role_list.empty?

    role_list.each do |role|
      person.role_list.add(role)
    end
    person.save!
  end
end
