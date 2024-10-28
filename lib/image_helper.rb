# frozen_string_literal: true

# /Users/liouyang/src/wildflower-platform/lib/image_helper.rb

module ImageHelper
  def self.cdn_url(s3_url)
    if ENV.fetch('ASSET_HOST', false)
      s3_url.sub("#{ENV.fetch('S3_BUCKET', 'ssj-local')}.s3.amazonaws.com", ENV.fetch('ASSET_HOST'))
    else
      s3_url
    end
  end
end
