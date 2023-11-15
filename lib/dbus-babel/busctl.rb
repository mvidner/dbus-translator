require_relative "command"

module DBusBabel
  class Busctl < Command
    def self.program
      "busctl"
    end

    # @param argv [Array<String>] CLI args where the first one is "busctl"
    # @return [Busctl]
    def self.parse_argv(argv)
      # busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetId
      # busctl get-property org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus Interfaces
      argv = argv.dup
      cmd_s = argv.shift
      raise LogicError unless cmd_s == program

      command = new
      command.address = :system
      command.quiet = false
      command.message = message = Message.new

      while argv.first.start_with? "-"
        case argv.first
        when /--destination=(.*)/
          message.destination = Regexp.last_match(1)
        when "--quiet", "-q"
          command.quiet = true
        when "--system"
          command.address = :system
        when "--user"
          command.address = :session
        else
          warn "Unrecognized option #{argv.first.inspect}"
        end
        argv.shift
      end

      # Parse positional arguments

      case argv.first
      when "call"
        message.type = :method_call
        argv.shift

        message.destination = argv.shift
        message.path = argv.shift
        message.interface = argv.shift
        message.member = argv.shift
      when "emit"
        message.type = :signal
        argv.shift

        message.path = argv.shift
        message.interface = argv.shift
        message.member = argv.shift
      when "get-property"
        message.type = :method_call
        argv.shift

        message.path = argv.shift
        p_interface = argv.shift
        p_member = argv.shift
        message.interface = "org.freedesktop.DBus.Properties"
        message.member = "Get"
        # TODO: typed data
        message.signature = "ss"
        message.body = [p_interface, p_member]
      else
        warn "Unrecognized verb #{argv.first.inspect}"
      end

      warn "Parameter passing not yet implemented" unless argv.empty?

      command
    end

    # @return [Array<String>] type value...
    def self.data_to_a(value)
      klass = value.class
      raise ArgumentError, value.inspect unless klass < DBus::Data::Base

      case value
      when DBus::Data::Basic
        [value.class.type_code, value.value]
      when DBus::Data::Variant
        [value.class.type_code] + data_to_a(value.exact_value)
      else
        # FIXME
        ["o", "/sorry_cannot_do_containers_yet"]
      end
    end

    def to_s
      addr_s = case address
               when :system
                 "--system"
               when :session
                 "--user"
               else
                 "--address=#{address}"
               end

      argv = [
        "busctl",
        quiet ? "--quiet" : nil,
        addr_s,
        "--",
        message.type == :method_call ? "call" : "emit",
        message.type == :method_call ? message.destination : nil,
        message.path,
        message.interface,
        message.member
      ].compact

      # if data_to_a gives ["s", "hello"], ["o", "/world"], ["u", "42"]
      # busctl wants ["sou", "hello", "/world", "42"]
      sig = ""
      args = []
      message.body.each do |arg|
        arg_sig, *arg_a = self.class.data_to_a(arg)
        sig += arg_sig
        args += arg_a
      end
      argv << sig unless sig.empty?
      argv += args

      argv.shelljoin
    end
  end
end
