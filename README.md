[![Gem Version](https://badge.fury.io/rb/ensure_it.png)](http://badge.fury.io/rb/ensure_it)
[![Code Climate](https://codeclimate.com/github/cybernetlab/ensure_it.png)](https://codeclimate.com/github/cybernetlab/ensure_it)
[![Build Status](https://travis-ci.org/cybernetlab/ensure_it.svg?branch=master)](https://travis-ci.org/cybernetlab/ensure_it)
[![Coverage Status](https://coveralls.io/repos/cybernetlab/ensure_it/badge.png?branch=master)](https://coveralls.io/r/cybernetlab/ensure_it?branch=master)

# EnsureIt

This library provides way to check and convert local variables for every-method usage, like arguments checking.

The main goal of EnsureIt is to provide as fast executed code as it possible with simple and usable syntax.

> **Note:** this library doesn't support ruby older than `2.0.0`

Simple example (you can find it at `examples/symbol.rb`):

```ruby
require 'rubygems'
require 'bundler/setup'
require 'ensure_it'

def test(arg)
  arg.ensure_symbol!
end

puts test(:symbol).inspect
puts test('string').inspect
puts test(0).inspect
```

gives following output:

```
$ ruby examples/symbol.rb
:symbol
:string
examples/symbol.rb:6:in `test': argument 'arg' of 'test' method should be a Symbol or a String (EnsureIt::Error)
  from examples/symbol.rb:11:in `<main>'
```

At first, string converted to symbol.

Secondary, note on error message. The library magically recognizes that `ensure_symbol!` called for `arg` argument of `test` method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ensure_it'
```

or for [refinements](#refinements) version:

```ruby
gem 'ensure_it', require: 'ensure_it_refined'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install ensure_it
```

## Configuration

For this moment only two configuration options available - global setting of smart errors (see [Usage section](#usage)) and default errors class (that will be used if it doesn't specified in methods calls):

```ruby
require 'ensure_it'

EnsureIt.configuration do |config|
  # config.errors = :standard
  config.errors = :smart
  config.error_class = ArgumentError
end
```

## Usage

EnsureIt does monkey-patching or provides refines (see [Refinements section](#refinements)) for generic ruby objects with set of `ensure_*` methods. So you can call this methods with everything in ruby. Corresponding to method name it returns `nil` (or raise exception for bang version of method, that name ended with `!`) for unusual or impossible type conversions and returns object of ensured type if conversion is possible.

For example `ensure_symbol` method returns symbol itself for Symbols, converted to symbol value for Strings and nil for all other. Same way `ensure_symbol!` returns symbol for String and Symbol, and raises exception for all other.

The special thing, that EnsureIt can do (and do it by default) is smart error messages in bang methods. In most cases, EnsureIt guesses right context in wich `ensure_*` method called and froms more informative message. It recognizes name of local variable if method called for variable like `my_var.ensure_symbol`, argument name, if variable is argument of method and method calls itself like `'some_string'.to_sym.ensure_symbol` - so `ensure_symbol` called on result of `to_sym` method. You can disable this functionality at all (see [Configuration section](#configuration)) or override globally configuration for any method call by `smart` option like this `:symbol.ensure_symbol(smart: true)` or `:symbol.ensure_symbol(smart: false)`. In any way, this `:smart` errors doesn't affect execution speed because the analyzing block of code executed only on exception - not on every `ensure_*` call.

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
  arg = arg.ensure_symbol!(
    error: ArgumentError,
    message: 'it\'s bad that #{subject} with name #{name} is not a symbol.' \
             ' Raised by #{method_name}'
  )
end

awesome(0)
```

will produce ArgumentError with message `it's bad that 'arg' of 'awesome' method with name arg is not a symbol. Raised in ensure_symbol!`.

### ensure_symbol, ensure_symbol!

Returns self for Symbol, converted value for String, nil (or raise) for other:

```ruby
:test.ensure_symbol # => :test
'test'.ensure_symbol # => :test
100.ensure_symbol # => nil
:test.esnure_symbol(values: %i(one two)) # => nil
:one.esnure_symbol(values: %i(one two)) # => :one
'test'.esnure_symbol(values: %i(one two)) # => nil
'one'.esnure_symbol(values: %i(one two)) # => :one
:Test.ensure_symbol(downcase: true) # => :test
'Test'.ensure_symbol(downcase: true) # => :test
```

### ensure_string, ensure_string!

By default, returns self for String, converted value for Symbol and nil (or raise) for other. With `numbers: true` option returns number, converted to string for Numeric and Rational objects:

```ruby
:test.ensure_string # => 'test'
'test'.ensure_string # => 'test'
100.ensure_string # => nil
100.ensure_string(numbers: true) # => '100'
:Test.ensure_string(downcase: true) # => 'test'
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
'010'.ensure_integer # => 10 !!! Octals are not accepted by default,
                     #           use octal: true for this
'010'.ensure_integer(octal: true) # => 8
100.4.ensure_integer # => 100
100.5.ensure_integer # => 101
true.ensure_integer # => nil
true.ensure_integer(boolean: true) # => 1
true.ensure_integer(boolean: 1000) # => 1000
```

Be aware that octal numbers, beginning with `0` is not accepted by default, because its usage is rarely, that more common situation to have leading zeroes in decimal numbers while loading data from something like csv file. To recognize zero-strated numbers as octals, use `octal: true` option.

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

### ensure_array, ensure_array!

By default, returns Array only for Array itself and **empty** array (not nil) for others. You can specify any number of arguments. Each argument can be a Proc or a symbol. If Proc given, it will be used as argument for `map` method of array, if symbol specified and it is one of `compact`, `flatten`, `reverse`, `rotate`, `shuffle`, `sort`, `sort_desc`, `uniq` then respective method wiill be called for array (for `sort_desc`, `sort` and then `reverse` will be called). In other cases specified method will be called for each array element inside `map` function. All arguments are processed in specified order. Also you can use `make: true` option to make array with object as single element if object is not an array (for `nil` empty array created). Examples:

```ruby
[1, nil, 2].ensure_array # => [1, nil, 2]
10.ensure_array # => []
10.ensure_array(default: nil) # => nil
10.ensure_array(make: true) # => [10]
nil.ensure_array(make: true) # => []
[1, nil, 2].ensure_array(:compact) # => [1, 2]
[1, [2, 3], 4].ensure_array(:flatten) # => [1, 2, 3, 4]
[1, [5, 6], 4].ensure_array(:flatten, :sort) # => [1, 4, 5, 6]
[1, [5, 6], 4].ensure_array(:flatten, :sort_desc) # => [6, 5, 4, 1]
arr = ['some', nil, :value]
arr.ensure_array(:ensure_symbol, :compact) # => [:some, :value]
arr.ensure_array(:ensure_symbol!, :compact) # => raise on second element
arr = ['some', :value]
arr.ensure_array(:to_s) # => ['some', 'value'] standard methods can be used
arr.ensure_array(:ensure_string, :to_sym) # => [:some, :value] you can chain methods
```

Simple usage example:

```ruby
require 'ensure_it'

class Awesome
  def self.define_getters(*args)
    args.ensure_array(:ensure_symbol, compact: true).each do |n|
      define_method(n) { instance_variable_get("@#{n}") }
    end
  end
end

Awesome.define_getters(:one, 'two', nil, false, Object, :three)
Awesome.methods(false) #=> [:one, :two, :three]
```

### ensure_hash, ensure_hash!

Returns Hash only for Hash itself and **empty** hash (not nil) for others. Symbolizes keys with `symbolize_keys: true` option:

```ruby
{some: 0, 'key' => 1}.ensure_hash # => {some: 0, 'key' => 1}
0.ensure_hash # => {}
0.ensure_hash(wrong: nil) # => nil
{some: 0, 'key' => 1}.ensure_hash(symbolize_keys: true) # => {some: 0, key: 0}
```

### ensure_instance_of, ensure_instance_of!

Returns self only if it instance of specified class or nil (or raise) elsewhere:

```ruby
10.ensure_instance_of(Fixnum) # => 10
10.0.ensure_instance_of(Fixnum) # => nil
10.0.ensure_instance_of(Fixnum, wrong: -1) # => -1
```

### ensure_class, ensure_class!

Returns self only if it is a class and optionally have specified ancestors or nil (or raise) elsewhere:

```ruby
10.ensure_class # => nil
String.ensure_class # => String
Fixnum.ensure_class(Integer) # => Fixnum
Float.ensure_class(Integer) # => nil

module CustomModule; end
class CustomArray < Array;
  include CustomModule
end
CustomArray.ensure_class(Enumerable, CustomModule) # => CustomArray
Array.ensure_class(Enumerable, CustomModule) # => nil
Array.ensure_class(Enumerable) # => Array
```

### Common options for all methods

|option|possible values|meaning|
|------|---------------|-------|
|`:values`|Array|(not used in `ensure_instance_of` and `ensure_hash`) an array of possible values. If value doesn't included in this array, default value returned or exception raised for bang methods. Note that library doesn't check types of this array elements, so be sure to specify array with right elements here.

### Common options for all non-bang methods

|option|possible values|meaning|
|------|---------------|-------|
|`:default`|any|if present then will be used as wrong value|

### Common options for all bang methods

|option|possible values|meaning|
|------|---------------|-------|
|`:message`|`String`|custom error message|
|`:error`|`Exception` class|custom error class|
|`:smart`|`true` or `false`|use smart errors|

## Refinements

Since ruby `2.0.0` [refinements](http://www.ruby-doc.org/core-2.1.1/doc/syntax/refinements_rdoc.html) mechanism intorduced and was experimental till `2.1.0`. Starting from `2.1.0` you can use it without warnings and in module and class scope.

EnsureIt is fully tested and working with refinements. But not by default and not for ruby `< 2.1.0`. To use refined version of EnsureIt (with zero-monkey-pathing) just require `ensure_it_refined` instead of `ensure_it`. If you use bundler, you can do it, by specifying `require: 'ensure_it_refined'` option for `gem 'ensure_it'` in your `Gemfile`:

```ruby
gem 'ensure_it', require: 'ensure_it_refined'
```

Or without bundler:

```ruby
# In you code initialization
require 'ensure_it_refined'
```

Then activate EnsureIt refines by `using EnsureIt` in needed scope:

```ruby
require 'ensure_it_refined'

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

Please read carefully [refinements](http://www.ruby-doc.org/core-2.1.1/doc/syntax/refinements_rdoc.html) documentation before using refined EnsureIt. Don't forget to call `using EnsureIt` in every file (not class or method if your class or method placed in many files) you need it.

## Benchmarking

In development mode a set of thor tasks under 'ensure_it:benchmark' namespace provided for benchmarking and profiling any library method. Also tasks `:non_bang`, `:bang` and `:all` provided for benchmarking all non-bang methods, all bang methods and allmost all methods respectively. To benchmark refined version of library, use `USE_REFINES=true` environment variable.

```sh
thor ensure_it:benchmark:symbol   # benchmark #ensure_symbol method
thor ensure_it:benchmark:symbol!  # benchmark #ensure_symbol! method
thor ensure_it:benchmark:non_bang # benchmark all non-bang methods
thor ensure_it:benchmark:all      # benchmark all library methods
USE_REFINES=true thor ensure_it:benchmark:all # benchmark refined library
```

Some results on my machine:

```
$ thor ensure_it:benchmark:symbol
Starting benchmarks for #ensure_symbol  with monkey-patched version of EnsureIt. Errors: standard. Ruby version: 2.1.1
ensure_it:      0.090000   0.000000   0.090000 (  0.083292)
standard way:   0.050000   0.000000   0.050000 (  0.051999)

$ thor ensure_it:benchmark:symbol!
Starting benchmarks for #ensure_symbol!  with monkey-patched version of EnsureIt. Errors: standard. Ruby version: 2.1.1
ensure_it:      6.350000   0.000000   6.350000 (  6.431325)
standard way:   0.440000   0.000000   0.440000 (  0.435714)
```

As you can see, call to `#esnure_symbol` is very close to standard type checking (number of benchmark runs - 10000), but bang version consumes much more time. This because we need to do some job to grab information from code for error message. And, of course, this code will execute only when error occured. Call to bang method for expected values (Symbols and Strings in this case) consume same time, as for normal `#ensure_symbol`.

Some options available for benchmarking.

### profiling
`-p` or `--profile=true` or `--profile=/ouput/dir`. Turns on profiling. If you specify profiling as boolean option, all progiling output will be putted into tmp dir under library root.

```sh
thor ensure_it:benchmark:symbol -p # benchmark and profile #ensure_symbol
thor ensure_it:benchmark:symbol --profile=/tmp/emsure_it
```

### number of examples
`-n` or `--number`. By default, all benchmarking procs runs 10000 times. You can specify another value with this option.

```sh
thor ensure_it:benchmark:all -n 1000
```

### smart errors
`-s` or `smart=true`. By default smart errors are off for time consuming. You can turn it on by this option.

```sh
thor ensure_it:benchmark:all -n 1000 -s
```

## Changelog

`0.1.5`
* added `EnsureIt.refined?`
* `ensure_array` `make` option added

`0.1.4`
* name_of option added to `ensure_symbol` and `ensure_string`
* string options added to `ensure_class`
* code optimization
* config_error configuration option added
* `ensure_array` interface changed

`0.1.3`
* downcase option added to `ensure_symbol` and `ensure_string`

`0.1.2`
* smart errors refactored
* benchmarking added
* `wrong` option changed to `default`
* `values` option added
* a lot of code refactored
* `ensure_it_refines` changed to `ensure_it_refined`

`0.1.1`
* fixed: no error_class in standard errors mode

`0.1.0`
* set of methods for beginning:
    - ensure_symbol
    - ensure_string
    - ensure_integer
    - ensure_float
    - ensure_array
    - ensure_hash
    - ensure_instance_of
    - ensure_class

## Versions

`0.x.x` is pre-release. After some testing in real applications, `1.x.x` as first release will be started.

## Todo

* class from string converting for ensure_class
* ensure_file_name
* ensure_var_name
* enlarge number of options for arrays and hashes
* block processing for arrays and hashes
* rspec matchers
* ActiveSupport and MongoId integration
* custom extending functionality support
* profiling distribution
* documenting with yard

## Contributing

1. Fork it (http://github.com/cybernetlab/ensure_it/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# License

The MIT License (MIT)

Copyright (c) 2014 Alexey Ovchinnikov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
