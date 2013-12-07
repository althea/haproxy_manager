require 'socket'
module HAProxyManager

  class HAPSocket
    def initialize(file)
      @file = file
    end

    def execute(cmd, &block)
      socket = UNIXSocket.new(@file)
      socket.write("#{cmd};")
      response = []
      socket.each do |line|
        data = line.strip
        next if data.empty?
        response << data
      end
      yield response if block_given?
      response
    end

    # returns bool if socket is available
    def self.available?(file)
      HAPSocket.new(file).available?
    end

    # returns bool if socket is available
    def available?
      begin
        execute('show info')
        true
      rescue Exception => e
        false
      end
    end

  end
end
