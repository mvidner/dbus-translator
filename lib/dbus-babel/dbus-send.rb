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
      command.quiet = true
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
      interface_member = argv.shift
      message.interface, _dot, message.member = interface_member.rpartition "."

      message.body = argv.map do |param|
        parse_data(param)
      end

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
        type = DBus::Type::Array[values.first.class.type_code]
        DBus::Data::Array.new(values, type: type)
      when "dict"
        key_type, value_type, value = value.split ":"
        values = value.split ","
        values = values.each_slice(2).map do |k, v|
          [parse_type(key_type, k), parse_type(value_type, v)]
        end
        type = DBus::Type::Hash[values.first[0].class.type_code, values.first[1].class.type_code]
        DBus::Data::Array.new(Hash[values], type: type)
      else
        parse_type(type, value)
      end
    end

    DATA_CLASSES = {
      "string" => DBus::Data::String,
      "objpath" => DBus::Data::ObjectPath,
      "double" => DBus::Data::Double,
      "boolean" => DBus::Data::Boolean,
      "byte" => DBus::Data::Byte,
      "int16" => DBus::Data::Int16,
      "uint16" => DBus::Data::UInt16,
      "int32" => DBus::Data::Int32,
      "uint32" => DBus::Data::UInt32,
      "int64" => DBus::Data::Int64,
      "uint64" => DBus::Data::UInt64,
      "variant" => DBus::Data::Variant,
      "array" => DBus::Data::Array
    }

    TYPE_NAMES = DATA_CLASSES.invert

    # parses simple types that dbus-send knows
    # Note that "signature" is omitted
    def self.parse_type(type, value)
      klass = DATA_CLASSES[type]
      raise ArgumentError, "Unknown data type #{type.inspect}" if klass.nil?

      if klass == DBus::Data::Double
        value = Float(value)
      elsif klass == DBus::Data::Boolean
        value = value == "true"
      elsif klass < DBus::Data::Int
        value = Integer(value)
      end

      klass.new(value)
    end

    def self.data_to_s(value)
      klass = value.class
      raise ArgumentError unless klass < DBus::Data::Base

      type_name = TYPE_NAMES[klass]
      # FIXME: only correct for simple types
      "#{type_name}:#{value.value}"
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
        message.destination ? "--dest=#{message.destination}" : nil,
        message.path,
        "#{message.interface}.#{message.member}"
      ].compact

      argv += message.body.map do |arg|
        self.class.data_to_s(arg)
      end

      argv.shelljoin
    end
  end
end
