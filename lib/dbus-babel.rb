require "dbus"
require "shellwords"

require_relative "dbus-babel/busctl"
require_relative "dbus-babel/command"
require_relative "dbus-babel/equal_by_instance_variables"
require_relative "dbus-babel/dbus-send"
require_relative "dbus-babel/gdbus"

module DBusBabel
  def parse_argv(argv)
    case argv.first
    when "dbus-send"
      DBusBabel::DBusSend.parse_argv(argv)
    when "busctl"
      DBusBabel::Busctl.parse_argv(argv)
    when "gdbus"
      DBusBabel::GDBus.parse_argv(argv)
    else
      warn "Unrecognized tool #{argv.first.inspect}"
      nil
    end
  end
  module_function :parse_argv

  class Message
    # @return [:signal,:method_call]
    attr_accessor :type

    # @return [String]
    attr_accessor :path, :interface, :member, :destination, :signature

    # @return [Array] of what
    attr_accessor :body

    include EqualByInstanceVariables

    def initialize(
      type: nil,
      path: nil,
      interface: nil,
      member: nil,
      destination: nil,
      signature: nil,
      body: nil
    )
      @type = type
      @path = path
      @interface = interface
      @member = member
      @destination = destination
      @signature = signature
      @body = body
    end
  end
end
