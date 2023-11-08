# dbus-send --session --print-reply --dest\=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Peer.GetMachineId
# busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Peer GetMachineId
# gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.Peer.GetMachineId
require_relative "spec_helper"

describe DBusBabel::Busctl do
  describe ".parse_argv" do
    it "parses a simple call" do
      argv = "busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Peer GetMachineId".split
      expected = DBusBabel::Busctl.new(
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
