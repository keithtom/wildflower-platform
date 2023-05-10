class SchoolRelationship < ApplicationRecord
  acts_as_taggable_on :roles # the roles held during the relationship

  belongs_to :school, touch: true
  belongs_to :person, touch: true

  # after_commit :reindex_models

  private

  # https://github.com/ankane/searchkick#indexing
  def reindex_models
    school.reindex
    person.reindex
  end
end
