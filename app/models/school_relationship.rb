class SchoolRelationship < ApplicationRecord
  include ApplicationRecord::ExternalIdentifier

  acts_as_paranoid
  acts_as_taggable_on :roles # the roles held during the relationship [Founder, Teacher Leader, Emerging Teacher Leader, Classroom Staff, Fellow, Other]

  belongs_to :school, touch: true
  belongs_to :person, touch: true

  after_commit :reindex_models
  after_create :set_name

  private

  # https://github.com/ankane/searchkick#indexing
  def reindex_models
    school.reindex
    person.reindex
  end

  def set_name
    self.name = "#{person.name} - #{school.name}"
    self.save!
  end
end
