# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School, type: :model do
  subject { create(:school) }

  its(:external_identifier) { is_expected.to_not be_nil }
end
