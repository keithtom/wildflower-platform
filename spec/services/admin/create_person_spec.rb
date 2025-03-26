require 'rails_helper'

RSpec.describe Admin::CreatePerson, type: :service do
  let(:valid_params) do
    {
      email: 'test@example.com',
      first_name: 'Test',
      last_name: 'User'
    }
  end

  describe '#run' do
    context 'when valid parameters are provided' do
      it 'creates a new inactive person' do
        expect { described_class.new(valid_params).run }
          .to change(Person, :count).by(1)

        person = Person.last
        expect(person.email).to eq(valid_params[:email])
        expect(person.first_name).to eq(valid_params[:first_name])
        expect(person.last_name).to eq(valid_params[:last_name])
        expect(person.active).to be false
      end

      it 'creates a new user associated with the person' do
        expect { described_class.new(valid_params).run }
          .to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq(valid_params[:email])
        expect(user.person).to eq(Person.last)
      end

      it 'sends an invite email' do
        expect(Users::SendInviteEmail).to receive(:call)
        described_class.new(valid_params).run
      end

      it 'returns the created person' do
        result = described_class.new(valid_params).run
        expect(result).to be_a(Person)
        expect(result.email).to eq(valid_params[:email])
      end
    end

    context 'when email is missing' do
      let(:invalid_params) { valid_params.except(:email) }

      it 'raises an error' do
        expect { described_class.new(invalid_params).run }
          .to raise_error(ActiveRecord::RecordInvalid,
                          'Validation failed: Email can\'t be blank, Email must be a valid email address')
      end

      it 'does not create a person' do
        expect do
            described_class.new(invalid_params).run
        rescue StandardError
            nil
        end.not_to change(Person, :count)
      end

      it 'does not create a user' do
        expect do
            described_class.new(invalid_params).run
        rescue StandardError
            nil
        end.not_to change(User, :count)
      end
    end

    context 'when person creation fails' do
      before do
        allow_any_instance_of(Person).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'does not create a user' do
        expect do
            described_class.new(valid_params).run
        rescue ActiveRecord::RecordInvalid
            nil
        end.not_to change(User, :count)
      end

      it 'does not send an invite email' do
        expect(Users::SendInviteEmail).not_to receive(:call)
        begin
          described_class.new(valid_params).run
        rescue ActiveRecord::RecordInvalid
          nil
        end
      end
    end

    context 'when user creation fails' do
      before do
        allow_any_instance_of(User).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'rolls back person creation' do
        expect do
            described_class.new(valid_params).run
        rescue ActiveRecord::RecordInvalid
            nil
        end.not_to change(Person, :count)
      end

      it 'does not send an invite email' do
        expect(Users::SendInviteEmail).not_to receive(:call)
        begin
          described_class.new(valid_params).run
        rescue ActiveRecord::RecordInvalid
          nil
        end
      end
    end
  end
end
