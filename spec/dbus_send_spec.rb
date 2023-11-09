require_relative "spec_helper"

describe DBusBabel::DBusSend do
  describe ".parse_argv" do
    it "parses a simple call" do
      argv = "dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Peer.GetMachineId".split
      expected = described_class.new(
        address: :session,
        message: DBusBabel::Message.new(
          type: :method_call,
          destination: "org.freedesktop.DBus",
          path: "/org/freedesktop/DBus",
          interface: "org.freedesktop.DBus.Peer",
          member: "GetMachineId",
          body: []
        ),
        quiet: false
      )
      cmd = described_class.parse_argv(argv)
      expect(cmd).to eq expected
    end

    it "parses a call with a string argument" do
      argv = "dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Debug.Stats.GetConnectionStats string::1.0".split
      expected = described_class.new(
        address: :session,
        message: DBusBabel::Message.new(
          type: :method_call,
          destination: "org.freedesktop.DBus",
          path: "/org/freedesktop/DBus",
          interface: "org.freedesktop.DBus.Debug.Stats",
          member: "GetConnectionStats",
          body: [
            DBus::Data::String.new(":1.0")
          ]
        ),
        quiet: false
      )
      cmd = described_class.parse_argv(argv)
      expect(cmd).to eq expected
    end
  end
end
