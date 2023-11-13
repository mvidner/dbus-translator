module DBusBabel
  class GDBus < Command
    def self.program
      "gdbus"
    end

    # @param argv [Array<String>] CLI args where the first one is "gdbus"
    # @return [GDBus]
    def self.parse_argv(argv)
      # gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.Peer.GetMachineId
      argv = argv.dup
      cmd_s = argv.shift
      raise LogicError unless cmd_s == program

      command = new
      command.quiet = false
      command.message = message = Message.new

      case argv.first
      when "call"
        message.type = :method_call
        argv.shift
      when "emit"
        message.type = :signal
        argv.shift
      else
        warn "Unrecognized verb #{argv.first.inspect}"
      end

      # TODO: parse also the assignment syntax, --opt=value
      while argv.first&.start_with? "-"
        case argv.first
        when "--dest"
          argv.shift
          message.destination = argv.shift
        when "--object-path"
          argv.shift
          message.path = argv.shift
        # TODO: fail if verb mismatches
        when "--method", "--signal"
          argv.shift
          interface_member = argv.shift
          message.interface, _dot, message.member = interface_member.rpartition "."
        when "--system"
          command.address = :system
          argv.shift
        when "--session"
          command.address = :session
          argv.shift
        when "--address"
          argv.shift
          command.address = argv.shift
        else
          warn "Unrecognized option #{argv.first.inspect}"
        end
      end

      # Parse positional arguments

      warn "Parameter passing not yet implemented" unless argv.empty?

      command
    end

    def self.data_to_s(value)
      # FIXME: only correct for simple types
      # TODO: your eyes. your eyes.
      value.value.inspect.gsub("=>", ":")
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
        "gdbus",
        message.type == :method_call ? "call" : "emit",
        addr_s,
        message.destination ? ["--dest", message.destination] : [],
        "--object-path", message.path,
        message.type == :method_call ? "--method" : "--signal",
        "#{message.interface}.#{message.member}",
        "--"
      ].flatten

      argv += message.body.map do |arg|
        self.class.data_to_s(arg)
      end

      argv.shelljoin
    end
  end
end
