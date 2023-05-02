# Serializer Tests

These tests should check for presentation/serialization concerns.
Usually the attributes and relationships we expect given a set of params.

## Gotchas

Jsonapi-serializer gem has a known issue.  We are using a work around in our models.
https://github.com/jsonapi-serializer/jsonapi-serializer/issues/53#issuecomment-579893172

For testing, we are using https://github.com/jsonapi-rb/jsonapi-rspec
Just watchout for `have_relationships` and `have_relationship`.  The latter is the only one with `with_data`.
Seems like data must match exactly.
