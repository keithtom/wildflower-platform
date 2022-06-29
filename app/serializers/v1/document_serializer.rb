# frozen_string_literal: true

module V1
  class DocumentSerializer < ApplicationSerializer
    attributes :type, :title, :link, :updated_at
  end
end
