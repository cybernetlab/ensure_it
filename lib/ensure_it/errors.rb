module EnsureIt
  class Error < StandardError; end

  class ErrorMessage
    attr_accessor :method_name, :subject, :subject_type, :inside, :backtrace
    attr_writer :message

    def initialize(method_name, message, backtrace)
      method_name = method_name.to_sym if method_name.is_a?(String)
      unless method_name.is_a?(Symbol)
        raise ArgumentError, 'EnsureIt: Wrong method_name argument for Error'
      end
      unless message.is_a?(String)
        raise ArgumentError, 'EnsureIt: Wrong message argument for Error'
      end
      @method_name, @message, @backtrace = method_name, message, backtrace
    end

    def subject_display_name
      display_name =
        if @subject.nil? && @subject_type != :unknown_method_result
          "subject of '#{method_name}' method"
        else
          case @subject_type
          when :local_variable then "local variable '#{@subject}'"
          when :instance_variable then "instance variable '@#{@subject}'"
          when :class_variable then "class variable '@@#{@subject}'"
          when :method_result then "return value of '#{subject}' method"
          when :unknown_method_result then 'return value of method'
          when :req_argument then "argument '#{subject}'"
          when :rest_argument then "argument '*#{subject}'"
          when :opt_argument then "optional argument '#{subject}'"
          when :key_argument then "key argument '#{subject}'"
          when :keyrest_argument then "key argument '**#{subject}'"
          when :block_argument then "block argument '&#{subject}'"
          else "subject of '#{method_name}' method"
          end
        end
      unless @inside.nil?
        display_name +=
          if !@subject_type.nil? && @subject_type.to_s =~ /_argument\z/
            " of '#{@inside}' method"
          else
            " inside '#{@inside}' method"
          end
      end
      display_name
    end

    def message
      @message.gsub(/\#\{subject\}/, subject_display_name)
    end
  end

  def self.raise_error(method_name, message, error_class = Error, **opts)
    error_class = Error unless error_class <= Exception
    error = ErrorMessage.new(method_name, message, caller[1..-1])
    if opts.key?(:smart) && opts[:smart] != true ||
       EnsureIt.config.errors != :smart
      raise error_class, error.message, error.backtrace
    end
    raise_smart_error(error, error_class, **opts)
  end

  def self.raise_smart_error(error, error_class, **opts)
    inspect_source(error, **opts)
    tp_count = 0
    error_obj = nil
    error_message = error.message
    error_backtrace = error.backtrace
    #
    # first trace point is to capture raise object before exitting
    # from :ensure_* method
    #
    # after that with second trace point we try to return from :ensure_* method
    # to caller and inspect code there for method name and arguments
    TracePoint.trace(:return, :raise) do |first_tp|
      if first_tp.event == :raise
        # save error object for patching
        error_obj = first_tp.raised_exception
      else
        # skip returns from :raise_smart_error and :raise_error
        tp_count += 1
        if tp_count > 1
          # at this moment we are at end of 'ensure_' method
          first_tp.disable
          TracePoint.trace(:return) do |second_tp|
            # skip return from :ensure_* method
            tp_count += 1
            if tp_count > 3
              # now we are in caller context
              second_tp.disable
              unless error_obj.nil?
                # inspect caller code
                inspect_code(second_tp, error, **opts)
                # patch error message
                error_obj.extend(Module.new do
                  @@ensure_it_message = error.message
                  def message; @@ensure_it_message; end
                end)
              end
            end
          end
        end
      end
    end
    raise error_class, error_message, error_backtrace
  end

  def self.inspect_source(error, **opts)
    file_name, line_no = error.backtrace.first.split(':', 2)
    return unless File.exist?(file_name)
    line_no = line_no.to_i
    line = read_line_number(file_name, line_no)
    return if line.nil?
    m_name = error.method_name
    m = /
      (?:(?<method_access>\.)|(?<class_access>@{1,2}))?
      (?<name>(?:[a-z_][a-zA-Z_0-9]*(?<modifier>[?!])?)|\))
      (?:
        (?<send>\.send\(\s*(?::#{m_name}|'#{m_name}'|"#{m_name}")\s*\))|
        (?:\.#{m_name}(?:[^a-zA-Z_0-9]|\z))
      )
    /x.match(line)
    return if m.nil? || m[:method_access].nil? && !m[:modifier].nil?
    error.subject = m[:name]
    error.subject_type = case
      when m[:class_access] then
        m[:class_access] == '@' ? :instance_variable : :class_variable
      when m[:name] == ')' then
        error.subject = nil
        :unknown_method_result
      when m[:method_access] then :method_result
      else :local_variable
      end
  end

  def self.inspect_code(tp, error, **opts)
    return if tp.method_id.nil?
    error.inside = tp.method_id
    begin
      method = eval("method(:#{tp.method_id})", tp.binding)
    rescue NameError
      return
    end
    param = method.parameters.find { |_, name| name.to_s == error.subject }
    unless param.nil?
      error.subject_type = "#{param[0]}_argument".to_sym
    end
  end

  def self.read_line_number(file_name, number)
    counter, line = 0, nil
    File.foreach(file_name) do |l|
      counter += 1
      if counter == number
        line = l.chomp!
        break
      end
    end
    line
  end

  private_class_method :raise_smart_error, :inspect_source, :inspect_code,
                       :read_line_number
end
