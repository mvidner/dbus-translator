require_relative "equal_by_instance_variables"

module DBusBabel
  class Command
    # @return [String,:system,:session]
    attr_accessor :address
    # @return [Message]
    attr_accessor :message
    # @return [Boolean]
    attr_accessor :quiet

    def initialize(command = nil, address: nil, message: nil, quiet: nil)
      if !command.nil?
        @address = command.address
        @message = command.message
        @quiet = command.quiet
      else
        @address = address
        @message = message
        @quiet = quiet
      end
    end

    include EqualByInstanceVariables
  end
end
