# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  subject { create(:address) }

  its(:external_identifier) { is_expected.to_not be_nil }
end
