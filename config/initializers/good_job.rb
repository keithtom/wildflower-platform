GoodJob.on_thread_error = -> (exception) { Highlight::H.instance.record_exception(exception) }