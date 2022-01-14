require 'rails_helper'

describe V1::SchoolSerializer do
  let(:school) { create(:school) }

  subject { described_class.new(school).serializable_hash }

  its(%i[data attributes]) { is_expected.to have_key(:name) }
  its(%i[data relationships]) { is_expected.to have_key(:address) }
end
