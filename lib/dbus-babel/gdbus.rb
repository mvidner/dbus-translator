module DBusBabel
  class GDBus < Command
    def to_s
      addr_s = case address
               when :system
                 "--system"
               when :session
                 "--session"
               else
                 "--address=#{address}"
               end

      argv = [
        "gdbus",
        message.type == :method_call ? "call" : "emit",
        addr_s,
        "--dest", message.destination,
        "--object-path", message.path,
        message.type == :method_call ? "--method" : "--signal",
        "#{message.interface}.#{message.member}"
      ].compact

      argv.shelljoin
    end
  end
end
