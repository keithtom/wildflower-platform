# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  subject { create(:role) }

  its(:external_identifier) { is_expected.to_not be_nil }
end
