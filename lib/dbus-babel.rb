require "shellwords"

require_relative "dbus-babel/busctl"
require_relative "dbus-babel/command"
require_relative "dbus-babel/dbus-send"
require_relative "dbus-babel/gdbus"

module DBusBabel
  class Message
    # @return [:signal,:method_call]
    attr_accessor :type

    # @return [String]
    attr_accessor :path, :interface, :member, :destination, :signature

    # @return [Array] of what
    attr_accessor :body
  end
end

