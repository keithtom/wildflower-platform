# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors
# Access-Control-Allow-Origin
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:3000", "localhost:3001", "https://my.wildflowerschools.org", "https://my-dev.wildflowerschools.org", "https://my-staging.wildflowerschools.org", "https://platform.wildflowerschools.org", "https://platform-dev.wildflowerschools.org", "https://platform-staging.wildflowerschools.org", /\Ahttps:\/\/.+\.vercel\.app\z/
    # origins "localhost:3000", "localhost:3001"
    resource "*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
