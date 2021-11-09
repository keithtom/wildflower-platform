# Serializers

Each controller, serializer, and routes are scoped to a version.
When updating to a version, please _DUPLICATE_ the entire set of files.

The only place of shared logic across all serializers controllers is the `application_serializer.rb`. Update it cautiously.

This is on purpose. Duplication isn't always bad.

Do NOT put authorization logic inside our serializers. They should be responsible solely for serializing, not determining what data to be serialized.
The controllers (or calling code) should be responsible for authorizing all serialized data and passing it into the serializer.

# Gotchas

The ApplicationSerializer defines `set_id` to use `external_identifier` for all subclasses.
But for some reason, relationships (belongs_to/has_many) won't use that.
You need to explicitly specify:
`has_many :messages, id_method_name: :external_identifier`
In order to have the relationships JSON use the right id.
References:
https://github.com/jsonapi-serializer/jsonapi-serializer/issues/45
https://github.com/Netflix/fast_jsonapi/issues/307#issuecomment-419542970
https://github.com/Netflix/fast_jsonapi#customizable-options
