require_relative "equal_by_instance_variables"

module DBusBabel
  class Command
    # @return [String,:system,:session]
    attr_accessor :address
    # @return [Boolean] true: peer connection, false: bus connection
    attr_accessor :peer
    # @return [Message]
    attr_accessor :message
    # @return [Boolean]
    attr_accessor :quiet

    def initialize(command = nil, address: nil, peer: nil, message: nil, quiet: nil)
      if !command.nil?
        @address = command.address
        @peer = command.peer
        @message = command.message
        @quiet = command.quiet
      else
        @address = address
        @peer = peer
        @message = message
        @quiet = quiet
      end
    end

    include EqualByInstanceVariables

    # @!method to_argv

    def to_s
      to_argv.shelljoin
    end

    def to_features_yaml
      yaml = "  #{self.class.program}: \"\\\n"
      to_argv.each do |arg|
        yaml += "    #{arg.to_s.shellescape} \\\n"
      end
      yaml += "\n    \"\n"
      yaml
    end
  end
end
