require 'benchmark'

if ENV['USE_REFINES'] == 'true'
  ENSURE_IT_REFINES = true
end

module EnsureIt
  class Benchmark < Thor
    OBJECTS = [
      nil, true, false, 0, 0.1, '1/3'.to_r, 'test', :test, Object, Class, ->{}
    ]

    class_option :smart, aliases: '-s', desc: 'use smart errors'
    class_option :count, aliases: '-n', desc: 'number of tests', default: 10000
    class_option :profile, aliases: '-p', desc: 'profile'

    desc 'symbol', 'runs benchmarks for ensure_symbol'
    def symbol
      run_benchmark :symbol, ensure_proc: ->(x) { x.ensure_symbol } do |x|
        x = x.to_sym if x.is_a?(String)
        x.is_a?(Symbol) ? x : nil
      end
    end

    desc 'symbol!', 'runs benchmarks for ensure_symbol!'
    def symbol!
      run_benchmark :symbol!, ensure_proc: ->(x) { x.ensure_symbol! } do |x|
        x = x.to_sym if x.is_a?(String)
        raise ArgumentError unless x.is_a?(Symbol)
      end
    end

    desc 'string', 'runs benchmarks for ensure_string'
    def string
      run_benchmark :string, ensure_proc: ->(x) { x.ensure_string } do |x|
        x = x.to_s if x.is_a?(Symbol)
        x.is_a?(String) ? x : nil
      end
    end

    desc 'string!', 'runs benchmarks for ensure_string!'
    def string!
      run_benchmark :string!, ensure_proc: ->(x) { x.ensure_string! } do |x|
        x = x.to_s if x.is_a?(Symbol)
        raise ArgumentError unless x.is_a?(String)
      end
    end

    desc 'non_bang', 'runs all non-bang benchmarks'
    def non_bang
      invoke(:symbol)
      invoke(:string)
    end

    desc 'bang', 'runs all bang benchmarks'
    def bang
      invoke(:symbol!)
      invoke(:string!)
    end

    desc 'all', 'runs all benchmarks'
    def all
      invoke(:non_bang)
      invoke(:bang)
    end

    no_commands do
      protected

      def run_benchmark(task_name, ensure_proc: proc {}, &standard_proc)
        load_ensure_it
        ensure_it, standard = [], []
        start_task(task_name)
        ::Benchmark.benchmark do |x|
          start_profile(task_name)
          ensure_it = x.report('ensure_it:    ') do
            OBJECTS.each do |obj|
              count.times { ensure_proc.call(obj) rescue ::EnsureIt::Error }
            end
          end
          standard = x.report('standard way: ') do
            OBJECTS.each do |obj|
              count.times { standard_proc.call(obj) rescue ArgumentError }
            end
          end
          end_profile(task_name)
        end
        end_task(task_name)
        [ensure_it, standard]
      end

      def start_task(task_name)
        text = "Starting benchmarks for #ensure_#{task_name} "
        if ENSURE_IT_REFINES == true
          text << ' with refined version of EnsureIt.'
        else
          text << ' with monkey-patched version of EnsureIt.'
        end
        text << " Errors: #{::EnsureIt.config.errors}."
        text << " Ruby version: #{RUBY_VERSION}"
        say text, :green
      end

      def end_task(task_name); end

      def start_profile(task_name)
        RubyProf.start if profile?
      end

      def end_profile(task_name)
        if profile?
          result = RubyProf.stop
          result.eliminate_methods!([
            /\ABenchmark/,
            /Thor::(?!Sandbox::EnsureIt::Benchmark#run_benchmark)/,
            /Integer#times/, /Struct::Tms/, /<Module::Process>/,
            /<Class::Time>/, /Time/
          ])
          file = File.join(profile_path, "ensure_#{task_name}.dot")
          unless Dir.exist?(File.dirname(file))
            FileUtils.mkpath File.dirname(file)
          end
          printer = RubyProf::DotPrinter.new(result)
          File.open(file, 'w') { |f| printer.print(f, min_percent: 0) }
          file = File.join(profile_path, "ensure_#{task_name}.txt")
          printer = RubyProf::GraphPrinter.new(result)
          File.open(file, 'w') { |f| printer.print(f, min_percent: 0) }
        end
      end

      def count
        n = options['count'].to_i
        n <= 0 ? 10000 : n
      end

      def refined?
        options['refined'] == 'refined' || options['refined'] == 'true'
      end

      def profile?
        options.key?('profile')
      end

      def profile_path
        if options['profile'] == 'profile' || options['profile'] == 'true'
          File.join(Dir.pwd, 'tmp')
        else
          File.expand_path(File.join('..', 'tmp'), __FILE__)
        end
      end

      def errors
        if options['smart'] == 'smart' || options['smart'] == true
          :smart
        else
          :standard
        end
      end

      def load_ensure_it
        lib = File.expand_path(File.join('..', '..'), __FILE__)
        $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
        require(refined? ? 'ensure_it_refines' : 'ensure_it')
        ::EnsureIt.configure do |config|
          config.errors = errors
        end
        require 'ruby-prof' if profile?
      end
    end
  end
end
