class ApplicationSerializer
  include JSONAPI::Serializer
  set_key_transform :camel_lower
  set_id :external_identifier # any object serialized to the outside world needs an external_identifier column

  def to_json(*_args)
    serializable_hash.to_json
  end
end
