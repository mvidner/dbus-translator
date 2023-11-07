module DBusBabel
  class Command
    # @return [String,:system,:session]
    attr_accessor :address
    # @return [Message]
    attr_accessor :message
    # @return [Boolean]
    attr_accessor :quiet

    def initialize(command = nil)
      return if command.nil?

      @address = command.address
      @message = command.message
      @quiet = command.quiet
    end
  end
end
