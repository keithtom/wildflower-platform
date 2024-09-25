# frozen_string_literal: true

class V1::ProfileImagesController < ApiController
  include Rails.application.routes.url_helpers

  def show
    person = Person.find_by!(external_identifier: params[:person_id])
    if person.profile_image.attached?
      width = params[:width]&.to_i || 320
      variant = person.profile_image.variant(resize_to_fill: [width, nil])

      # Ensure the variant is processed before redirecting
      variant_processed = variant.processed

      # Generate the URL for the processed variant
      url = rails_representation_url(variant_processed, only_path: false)
      redirect_to url
    else
      render json: { error: 'Profile image not found' }, status: :not_found
    end
  end
end
