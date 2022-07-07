require 'json'

module JsonHelper
  def json_response
    JSON.parse(response.body)
  end

  def json_document
    subject.with_indifferent_access
  end
end
