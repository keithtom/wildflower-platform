require 'rails_helper'

RSpec.describe 'Password Reset', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'POST /users/password_reset' do
    context 'when user exists' do
      let!(:user) { create(:user, email: 'test@example.com') }

      it 'generates a new token and sends password reset email' do
        expect do
          post password_reset_path, params: { email: user.email }, headers:
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to have_http_status(:success)
        expect(json_response['message']).to eq('Email sent successfully')

        # Verify email content
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to include('Password Reset Request')
        expect(email.to).to eq([user.email])
        expect(email.body.encoded).to include('reset your password')
        expect(email.body.encoded).to include('will expire in 24 hours')
      end

      it 'generates a new authentication token' do
        original_token = user.authentication_token

        post password_reset_path, params: { email: user.email }, headers: headers

        user.reload
        expect(user.authentication_token).not_to eq(original_token)
      end

      it 'is case insensitive with email' do
        expect do
          post password_reset_path, params: { email: user.email.upcase }, headers:
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when user does not exist' do
      it 'returns success but does not send email' do
        expect do
          post password_reset_path, params: { email: 'nonexistent@example.com' }, headers:
        end.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to have_http_status(:success)
        expect(json_response['message']).to eq('Email sent successfully')
      end
    end

    context 'when email parameter is missing' do
      it 'returns success but does not send email' do
        expect do
          post password_reset_path, params: {}, headers:
        end.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to have_http_status(:success)
        expect(json_response['message']).to eq('Email sent successfully')
      end
    end
  end
end
