# frozen_string_literal: true

class V1::ProfileImagesController < ApiController
  include Rails.application.routes.url_helpers

  skip_before_action :authenticate_user!, only: [:show]
  before_action :verify_signed_id, only: [:show]

  def show
    ActiveStorage::Current.url_options = { host: request.base_url }

    if @person.profile_image.attached?
      width = params[:width]&.to_i || 320
      variant = @person.profile_image.variant(resize_to_fill: [width, nil])

      # Ensure the variant is processed before redirecting
      variant_processed = variant.processed

      # Generate the URL for the processed variant
      url = variant_processed.url
      redirect_to(ImageHelper.cdn_url(url), allow_other_host: true)
    else
      render json: { error: 'Profile image not found' }, status: :not_found
    end
  end

  private

  def verify_signed_id
    @person = Person.find_signed!(params[:signed_id])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
