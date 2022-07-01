require 'rails_helper'

describe V1::Advice::DecisionSerializer do
  let(:decision) { build(:advice_decision ) }

  subject { described_class.new(decision).serializable_hash }

  its(%i[data attributes]) { is_expected.to have_key(:title) }
  its(%i[data relationships]) { is_expected.to have_key(:stakeholders) }
  its(%i[data relationships]) { is_expected.to have_key(:documents) }

  # add ability to do eager loading
  # no activities unless eager loaded
end
