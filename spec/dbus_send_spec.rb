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
          member: "GetMachineId"
        ),
        quiet: false
      )
      cmd = described_class.parse_argv(argv)
      expect(cmd).to eq expected
    end
  end
end
