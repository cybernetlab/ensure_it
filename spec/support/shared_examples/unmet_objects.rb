using EnsureIt if ENSURE_IT_REFINES

shared_examples 'niller for unmet objects' do |*except|
  it 'returns nil' do
    expect(
      general_objects.except(*except).map { |x| call_for(x) }.compact
    ).to be_empty
  end
end

shared_examples 'banger for unmet objects' do |*except,
                                               error: EnsureIt::Error,
                                               message: nil|
  it 'raises error' do
    objects = general_objects.except(*except)
    expect(EnsureIt).to receive(:raise_error)
      .exactly(objects.size).times.and_call_original
    objects.each do |obj|
      expect {
        call_for(obj)
      }.to raise_error(*[error, message].compact)
    end
  end
end
