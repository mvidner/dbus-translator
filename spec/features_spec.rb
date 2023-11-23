require_relative "spec_helper"
require "yaml"

describe "Feature Matrix" do
  features_yaml = YAML.safe_load_file("#{__dir__}/features.yaml")
  tools = [DBusBabel::DBusSend, DBusBabel::Busctl, DBusBabel::GDBus]

  features_yaml.each do |feat|
    next if feat["skip"]

    describe(feat.fetch("name")) do
      commands = tools.map do |tool_k|
        cmdline = feat[tool_k.program]
        command = DBusBabel.parse_argv(cmdline.split)
      end

      context "the commands mean the same thing" do
        (commands + [commands.first]).each_cons(2) do |a, b|
          it "#{a.class.program} === #{b.class.program}" do
            expect(a).to match b
          end
        end
      end
    end
  end
end
