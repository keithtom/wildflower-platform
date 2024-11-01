# frozen_string_literal: true

module V1
  class AdminDocumentSerializer < ApplicationSerializer
    set_id :id
    attributes :inheritance_type, :title, :title_es, :link, :updated_at
  end
end
