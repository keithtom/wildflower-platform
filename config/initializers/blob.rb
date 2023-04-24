## need this in order for rails_blob_path() to work in the serializers.
Rails.application.reloader.to_prepare do
 ActiveStorage::Blob
end
