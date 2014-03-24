RSpec::Matchers.define :warn do |message|
  match do |block|
    output = fake_stderr(&block)
    message.is_a?(Regexp) ? message.match(output) : output.include?(message)
  end

  description do
    "warn with message \"#{message}\""
  end

  failure_message_for_should do
    "expected to #{description}"
  end

  failure_message_for_should_not do
    "expected to not #{description}"
  end

  # Fake STDERR and return a string written to it.
  def fake_stderr
    original_stderr = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = original_stderr
  end
end
