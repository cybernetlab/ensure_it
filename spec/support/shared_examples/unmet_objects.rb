#using EnsureIt if ENSURE_IT_REFINES

def fake_method; end

FIXNUM_MAX = (2 ** (0.size * 8 - 2) - 1)
BIGNUM = FIXNUM_MAX + 100
FIXNUM = FIXNUM_MAX - 100
GENERAL_OBJECTS = [
  [], {}, FIXNUM, BIGNUM, 0.1, true, false, nil, 0..5,
  '2/3'.to_r, /regexp/, 'string', :symbol,
  ->{}, proc {}, method(:fake_method),
  Object.new, Class.new, Module.new, Struct.new(:field), Time.new
]

def compose_objects(add, except)
  except = [except] unless except.is_a?(Array)
  add = [add] unless add.is_a?(Array)
  except = except.flatten.select { |x| x.is_a?(Class) }
  objects = GENERAL_OBJECTS.reject { |obj| except.any? { |c| obj.is_a?(c) } }
  objects.concat(add)
end

shared_examples 'niller for unmet objects' do |*add, except: []|
  it 'returns nil' do
    expect(
      compose_objects(add, except).map { |x| call_for(x) }.compact
    ).to be_empty
  end
end

shared_examples 'banger for unmet objects' do |*add, except: [],
                                               error: EnsureIt::Error,
                                               message: nil|
  it 'raises error' do
    objects = compose_objects(add, except)
    expect(EnsureIt).to receive(:raise_error)
      .exactly(objects.size).times.and_call_original
    objects.each do |obj|
      expect {
        call_for(obj)
      }.to raise_error(*[error, message].compact)
    end
  end
end
