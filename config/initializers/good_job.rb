GoodJob.on_thread_error = -> (exception) do 
  Highlight::H.instance.record_exception(exception)
  SlackClient.chat_postMessage(channel: '#circle-platform', text: exception.message, as_user: true)
end