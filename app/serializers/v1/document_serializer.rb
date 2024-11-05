# frozen_string_literal: true

module V1
  class DocumentSerializer < ApplicationSerializer
    attributes :inheritance_type, :title, :title_es, :link, :updated_at
  end
end
