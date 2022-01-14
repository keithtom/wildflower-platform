# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Skill, type: :model do
  subject { create(:skill) }

  its(:external_identifier) { is_expected.to_not be_nil }
end
