module V1::Imageable
  extend ActiveSupport::Concern
  class_methods do
    def image_url(person)
      if person.profile_image.attached?
        signed_id = person.signed_id(expires_in: 1.hour)
        Rails.application.routes.url_helpers.v1_person_profile_image_url(
          person_id: person.external_identifier, signed_id:
        )
      elsif person.image_url.present?
        person.image_url
      end
    end

    def logo_url(school)
      if school.logo_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(school.logo_image)
      elsif school.logo_url.present?
        school.logo_url
      end
    end

    def hero_image_url(school)
      if school.banner_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(school.banner_image)
      elsif school.hero_image_url.present?
        school.hero_image_url
      end
    end
  end
end
