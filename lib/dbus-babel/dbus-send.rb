module DBusBabel
  class DBusSend < Command
    # @param argv [Array<String>] CLI args where the first one is "dbus-send"
    # @return [DBusSend]
    def self.parse_argv(argv)
      # $ dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetId
      argv = argv.dup
      cmd_s = argv.shift
      raise LogicError unless cmd_s == "dbus-send"

      command = new
      command.address = :session

      command.message = message = Message.new
      message.type = :signal
      # what if --dest is omitted?
      message.destination = nil

      while argv.first.start_with? "--"
        case argv.first
        when /--dest=(.*)/
          message.destination = Regexp.last_match(1)
        when "--print-reply", "--print-reply=literal"
          command.quiet = false
          message.type = :method_call
        when "--system"
          command.address = :system
        when "--session"
          command.address = :session
        else
          warn "Unrecognized option #{argv.first.inspect}"
        end
        argv.shift
      end

      # Parse positional arguments
      message.path = argv.shift
      interface_method = argv.shift
      message.interface, _dot, message.member = interface_method.rpartition "."

      warn "Parameter passing not yet implemented" unless argv.empty?

      command
    end

    # Parse one data argument
    # @return [DBus::Data::Base]
    def self.parse_data(s)
      type, colon, value = s.partition ":"
      raise ArgumentError unless colon == ":"

      case type
      when "variant"
        inner_type, colon, value = value.partition ":"
        raise ArgumentError unless colon == ":"

        value = parse_type(inner_type, value)
        DBus::Data::Variant.new(value, member_type: nil)
      when "array"
        inner_type, colon, value = value.partition ":"
        raise ArgumentError unless colon == ":"

        # OMG DBus::Data::Array API is so opaque after a while
        # TODO what if the item contains a comma
        values = value.split ","
        values = values.map do |v|
          parse_type(inner_type, v)
        end

        # FIXME: empty array
        DBus::Array.new(values, type: DBus::Type::Array[values.first.type_code])
      when "dict"
        raise NotImplementedError
      else
        parse_type(type, value)
      end
    end

    # parses simple types that dbus-send knows
    # Note that "signature" is omitted
    def self.parse_type(type, value)
      case type
      when "string"
        DBus::Data::String.new(value)
      when "objpath"
        DBus::Data::ObjectPath.new(value)
      when "double"
        DBus::Data::Double.new(Float(value))
      when "boolean"
        DBus::Data::Boolean.new(value == "true")
      when "byte"
        DBus::Data::Byte.new(Integer(value))
      when "int16"
        DBus::Data::Int16.new(Integer(value))
      when "uint16"
        DBus::Data::UInt16.new(Integer(value))
      when "int32"
        DBus::Data::Int32.new(Integer(value))
      when "uint32"
        DBus::Data::UInt32.new(Integer(value))
      when "int64"
        DBus::Data::Int64.new(Integer(value))
      when "uint64"
        DBus::Data::UInt64.new(Integer(value))
      else
        raise ArgumentError, "Unknown data type #{type.inspect}"
      end
    end

    def to_s
      addr_s = case address
               when :system
                 "--system"
               when :session
                 "--session"
               else
                 "--address=#{address}"
               end

      argv = [
        "dbus-send",
        addr_s,
        message.type == :method_call ? "--print-reply" : nil,
        "--dest=#{message.destination}",
        message.path,
        "#{message.interface}.#{message.member}"
      ].compact

      argv.shelljoin
    end
  end
end
