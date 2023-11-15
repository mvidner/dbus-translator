require_relative "spec_helper"

describe DBusBabel::DBusSend do
  describe ".parse_argv" do
    it "parses a simple call" do
      argv = "dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.Peer.GetMachineId".split
      expected = described_class.new(
        address: :session,
        peer: false,
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
        peer: false,
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

    it "parses a call with complex arguments" do
      # taken from man dbus-send
      argv_s = <<CMD
      dbus-send --dest=org.freedesktop.ExampleName     \
      /org/freedesktop/sample/object/name              \
      org.freedesktop.ExampleInterface.ExampleMethod   \
      int32:47 string:'hello world' double:65.32       \
      array:string:"1st item","next item","last item"  \
      variant:int32:-8                                 \
      objpath:/org/freedesktop/sample/object/name
CMD

      # omitted because dict _comparison_ is broken
      #       dict:string:int32:"one",1,"two",2,"three",3      \
      #

      argv = Shellwords.split(argv_s)

      expected = described_class.new(
        address: :session,
        peer: false,
        message: DBusBabel::Message.new(
          type: :signal,
          destination: "org.freedesktop.ExampleName",
          path: "/org/freedesktop/sample/object/name",
          interface: "org.freedesktop.ExampleInterface",
          member: "ExampleMethod",
          body: [
            DBus::Data::Int32.new(47),
            DBus::Data::String.new("hello world"),
            DBus::Data::Double.new(65.32),
            DBus::Data.make_typed("as", ["1st item", "next item", "last item"]),
            # DBus::Data.make_typed("a{si}", { "one" => 1, "two" => 2, "three" => 3 }),
            DBus::Data::Variant.new(-8, member_type: "i"),
            DBus::Data::ObjectPath.new("/org/freedesktop/sample/object/name")
          ]
        ),
        quiet: true
      )
      cmd = described_class.parse_argv(argv)
      expect(cmd).to match expected
    end
  end
end
