require 'rails_helper'

describe V1::PersonSerializer do
  let(:person) { create(:person ) }

  subject { described_class.new(person).serializable_hash }

  its(%i[data attributes]) { is_expected.to have_key(:email) }
  its(%i[data relationships]) { is_expected.to have_key(:roles) }
end
