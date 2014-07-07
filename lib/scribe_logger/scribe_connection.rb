module Scribe
  class ScribeConnection
    def initialize(server, evented)
      options = { :protocol_extra_params => false }
      options.update({ :transport => Thrift::EventMachineTransport }) if evented == true
      @client = ::ThriftClient.new(ScribeThrift::Client, [server], options)
    end

    def log(category, message)
      entry = ScribeThrift::LogEntry.new(:message => message, :category => category)
      @client.Log([entry])
    end

    def reconnect!
      @client.connect!
    end
  end
end
