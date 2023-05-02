# highlight.io

require "highlight"

Highlight::H.new(ENV["HIGHLIGHT_SECRET"]) # only production

highlightLogger = Highlight::Logger.new(nil)
Rails.logger.extend(ActiveSupport::Logger.broadcast(highlightLogger))