module Workflow
  class Instance::Workflow < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    acts_as_paranoid
    audited

    belongs_to :definition, class_name: 'Workflow::Definition::Workflow'

    has_many :processes
    has_many :steps, through: :processes

    has_many :dependencies

    belongs_to :school, optional: true

    delegate :name, to: :definition

    delegate :description, to: :definition

    delegate :version, to: :definition

    delegate :recurring, to: :definition

    scope :visible, -> { where(visible: true) }
  end
end
