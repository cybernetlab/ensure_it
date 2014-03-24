# EnsureIt

This library provides way to check and converts local variables for every-method usage, like arguments checking.

The main goal of EnsureIt is to provide as fast executed code as it possible with simple and usable syntax.

> **Note:** this library doesn't support ruby older than `2.0.0`

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'ensure_it'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install ensure_it
```

## Usage

EnsureIt does monkey-patching or provides refines (see [Refinements section](#refinements)) for general ruby objects with set of `ensure_*` methods. So you can call this methods with everything in ruby. Corresponding to method name it returns `nil` (or raise exception for bang version of method, that name ended with `!`) for unusual or impossible type conversions and returns object of ensured type if conversion is possible.

For example `ensure_symbol` method returns symbol itself for Symbols, converted to symbol value for Strings and nil for all other. Same way `ensure_symbol!` returns symbol for String and Symbol, and raises exception for all other.

The special thing, that EnsureIt can do (and do it by default) is smart error messages in bang methods. In most cases, EnsureIt guesses right context in wich `ensure_*` method called and froms more informative message. It recognizes name of local variable if method called for variable like `my_var.ensure_symbol`, argument name, if variable is argument of method and method calls itself like `'some_string'.to_sym.ensure_symbol` - so `ensure_symbol` called on result of `to_sym` method. You can disable this functionality at all (see [Configuration section](configuration)) or override globally configuration for any method call by `smart` option like this `:symbol.ensure_symbol(smart: true)` or `:symbol.ensure_symbol(smart: false)`. In any way, this `:smart` errors doesn't affect execution speed because the analyzing block of code executed only on exception - not on every `ensure_*` call.

For example, following code

```ruby
def awesome(arg)
  arg = arg.ensure_symbol!
end

awesome(0)
```

will produce error message `argument 'arg' of 'awesome' method should be a Symbol or a String`.

For bang methods you can override error class with `error` option and error message with `message` option. In message you can specify a placeholder for subject as `#{subject}`, just subject name as `#{name}` and method name as `#{method_name}`. For example:

```ruby
def awesome(arg)
  arg = arg.ensure_symbol!(message: 'it\' unusual that #{subject} with name #{name} is not a symbol. Raised by #{method_name}')
end

awesome(0)
```

will produce error message `it's unusual that 'arg' of 'awesome' method with name arg is not a symbol. Raised in ensure_symbol!`.

### ensure_symbol, ensure_symbol!

Returns self for Symbol, converted value for String, nil (or raise) for other.

### ensure_string, ensure_string!

By default, returns self for String, converted value for Symbol and nil (or raise) for other. With `numbers: true` option returns number, converted to string for Numeric and Rational objects:

```ruby
:test.ensure_string # => 'test'
'test'.ensure_string # => 'test'
100.ensure_string # => nil
100.ensure_string(numbers: true) # => '100'
```

### ensure_integer, ensure_integer!

By default, returns Fixnum or Bignum for Integer itself, rounded value for Float, converted Strings with strong check ('123test' will return nil) and nil (or raise) for other. With `boolean: true` option returns `0` for `false` and `1` for `true`, with `boolean: Fixnum-value` returns `0` for false and specified value for true:

```ruby
:test.ensure_integer # => nil
:'100'.ensure_integer # => nil
'100'.ensure_integer # => 100
'1_200'.ensure_integer # => 1200
'0x0a'.ensure_integer # => 10
'0b100'.ensure_integer # => 4
'010'.ensure_integer # => 10 !!! Octals are not accepted by default, use octal: true for this
'010'.ensure_integer(octal: true) # => 8
100.4.ensure_integer # => 100
100.5.ensure_integer # => 101
true.ensure_integer # => nil
true.ensure_integer(boolean: true) # => 1
true.ensure_integer(boolean: 1000) # => 1000
```

Be aware that octal numbers, beginning with `0` is not accepted by default, because its usage is rarely, that more common situaion to have leading zeroes in decimal numbers while loading data from something like csv file. To recognize zero-strated numbers as octals, use `octal: true` option.

### ensure_float, ensure_float!

By default, returns Float for Numerics, converted Strings with strong check ('123test' will return nil) and nil (or raise) for other:

```ruby
:test.ensure_float # => nil
:'100'.ensure_float # => nil
'100'.ensure_float # => 100.0
'.1'.ensure_float # => 0.1
'1e3'.ensure_float # => 1000.0
100.ensure_float # => 100.0
100.5.ensure_float # => 100.5
('1/2').to_r.ensure_float # => 0.5
true.ensure_float # => nil
```

## Refinements

Since ruby `2.0.0` [refinements](http://www.ruby-doc.org/core-2.1.1/doc/syntax/refinements_rdoc.html) mechanism intorduced and was experimental till `2.1.0`. Starting from `2.1.0` you can use it without warnings and in module and class scope.

EnsureIt is fully tested and working with refinements. But not by default and not for ruby `< 2.1.0`. To use refined version of EnsureIt (with zero-monkey-pathing) just require `ensure_it_refines` instead `ensure_it`. If you use bundler, you can do it, by specifying `require: 'ensure_it_refines'` option for `gem 'ensure_it'` in your `Gemfile`:

```ruby
gem 'ensure_it', require: 'ensure_it_refines'
```

Or without bundler:

```ruby
# In you code initialization
require 'ensure_it_refines'
```

Then activate EnsureIt refines by `using EnsureIt` in needed scope:

```ruby
require 'ensure_it_refines'

class AwesomeClass
  using EnsureIt

  def awesome_method(arg)
    arg = arg.ensure_symbol!
  end
end

AwesomeClass.new.awesome_method(0) # => raises EnsureIt::Error with message
                                   # "argument 'arg' of 'awesome_method' 
                                   #  method should be a Symbol or a String"
```

Please read carefully refinements documentation before refined EnsureIt. Don't forget to call `using EnsureIt` in every file (not class or method if your class or method placed in many files) you need it.

## Changelog

`0.1.0`
* set of methods for beginning:
    - ensure_symbol
    - ensure_string
    - ensure_integer
    - ensure_float
    - ensure_array
    - ensure_hash
    - ensure_instance_of

## Versions

`0.x.x` is pre-release. After some testing in real applications, `1.x.x` as first release will be started.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/skeleton/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
