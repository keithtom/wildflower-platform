module V1::Locationable
  extend ActiveSupport::Concern

  class_methods do
    def location(locationable)
      if locationable.address
        if locationable.address.city.present? && locationable.address.state.present?
          "#{locationable.address.city}, #{locationable.address.state}"
        elsif locationable.address.city.blank? && locationable.address.state.present?
          "#{locationable.address.state}"
        elsif locationable.address.city.present?
          "#{locationable.address.city}"
        end
      end
    end
  end
end
