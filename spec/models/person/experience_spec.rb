# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person::Experience, type: :model do
  subject { create(:person_experience) }

  its(:external_identifier) { is_expected.to_not be_nil }
end
