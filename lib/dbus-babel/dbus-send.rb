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
