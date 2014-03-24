RSpec::Matchers.define :warn do |message|
  match do |block|
    output = capture_stderr(&block)
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
  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end
end
