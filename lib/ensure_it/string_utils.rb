module EnsureIt
  module StringUtils
    NAME_TYPES = %i(local instance_variable class_variable setter getter
                    checker bang method class file)
    NAME_REGEXP = /\A
      (?<class_access>@{1,2})?
      (?<name>[a-z_][a-zA-Z_0-9]*)
      (?<modifier>[?!=])?
    \z/x
    CLASS_NAME_REGEXP = /\A
      [A-Z][a-zA-Z_0-9]*(?:::[A-Z][a-zA-Z_0-9]*)*
    \z/x
    CLASS_NAME_DOWNCASE_REGEXP = /\A
      [a-z][a-zA-Z_0-9]*(?:\/[a-z][a-zA-Z_0-9]*)*
    \z/x
    FILE_EXTENSION_REGEXP = /\A(?<name>.*)(?<ext>\.[^.]+)\z/

    using EnsureIt if ENSURE_IT_REFINED

    def self.ensure_name(str, name_of: nil, **opts)
      str = str.ensure_string!
      name_of = name_of.ensure_symbol(
        downcase: true,
        values: NAME_TYPES,
        default: NAME_TYPES[0]
      )
      if name_of == :class
        m = CLASS_NAME_REGEXP.match(str)
        if m.nil?
          return nil if opts[:downcase] != true
          m = CLASS_NAME_DOWNCASE_REGEXP.match(str)
          return nil if m.nil?
          str = str
            .split('/')
            .map { |x| x.split('_').map(&:capitalize).join }
            .join('::')
        end
        if opts[:exist] == true
          begin
            Object.const_get(str)
          rescue NameError
            return nil
          end
        end
        str
      elsif name_of == :file
        if extension = opts[:extension].ensure_string
          extension.gsub!(/\A\.+/, '')
          str.gsub!(/\A\.+/, '')
          if str =~ FILE_EXTENSION_REGEXP
            str.gsub!(FILE_EXTENSION_REGEXP, '\1.' + extension)
          else
            str = [str, extension].join('.')
          end
        end
        if opts[:exist] == true
          if File.exist?(File.expand_path(str, Dir.pwd))
            str = File.expand_path(str, Dir.pwd)
          else
            return nil
          end
        else
          str = File.expand_path(str, Dir.pwd)
        end
        str
      else
        m = NAME_REGEXP.match(str)
        return nil if m.nil?
        case name_of
        when :local, :getter then m[:name]
        when :instance_variable then '@' + m[:name]
        when :class_variable then '@@' + m[:name]
        when :setter then m[:name] + '='
        when :checker then m[:name] + '?'
        when :bang then m[:name] + '!'
        when :method then m[:name] + (m[:modifier] || '')
        else m[:name]
        end
      end
    end
  end
end
