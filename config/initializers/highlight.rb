# highlight.io

require "highlight"

Highlight::H.new(ENV['HIGHLIGHT_SECRET']) do |c|
  c.service_name = 'wildflower_platform_api'
  c.service_version = '1.0'
end
 # only production

highlightLogger = Highlight::Logger.new(nil)
Rails.logger.extend(ActiveSupport::Logger.broadcast(highlightLogger))