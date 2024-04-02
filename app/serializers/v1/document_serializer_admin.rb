# frozen_string_literal: true

module V1
  class DocumentSerializerAdmin < ApplicationSerializer
    set_id :id

    attributes :inheritance_type, :title, :link, :updated_at
  end
end
