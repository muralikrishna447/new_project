# https://github.com/newrelic/rpm/issues/348

module NewRelic::Agent::Instrumentation::MiddlewareTracing

  def capture_response_content_length(state, result)
    if result.is_a?(Array) && state.current_transaction
      _, headers, _ = result
      length = headers[CONTENT_LENGTH]
      length = length.reduce(0){|sum, h| sum + h.to_i} if length.is_a?(Array)
      state.current_transaction.response_content_length = length
    end
  end

end
