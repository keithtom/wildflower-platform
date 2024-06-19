Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

SlackClient = Slack::Web::Client.new