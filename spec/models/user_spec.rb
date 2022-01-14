# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user, password: "abc123") }

  its(:external_identifier) { is_expected.to_not be_nil }
end
