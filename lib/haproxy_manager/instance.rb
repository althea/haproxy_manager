require 'socket'
module HAProxyManager
  class Instance
    def initialize(socket)
      @socket = HAPSocket.new(socket)
      @print_response = Proc.new {|response| puts response}
      backends = @socket.execute( "show stat -1 4 -1" )[1..-1].collect{|item| item.split(",")[0..1]}
      @backends  = backends.inject({}){|hash, items| (hash[items[0]] ||=[]) << items[1]; hash}
    end

    # Diables a server in the server in a backend for maintenance.
    # If backend is not specified then all the backends in which the serverid exists are disabled.

    def disable(serverid, backend = nil)
      all_servers(serverid, backend).each do |item|
        @socket.exec "disable server #{item[0]}/#{item[1]}", &@print_response
      end
    end

    # Enables a server in the server in a backend.
    # If backend is not specified then all the backends in which the serverid exists are enabled.
    def enable(serverid, backend = nil)
      all_servers(serverid, backend).each do |item|
        @socket.exec "enable server #{item[0]}/#{item[1]}", &@print_response
      end
    end

    def backends
      @backends.keys
    end

    def servers(backend=nil)
      backend.nil? ? @backends.values.flatten : @backends[backend]
    end

    private
    def all_servers(serverid, backend)
      if(backend.nil?)
        items = @backends.collect{|a, b| [a, serverid] if b.include?(serverid)}.compact
      else
        items = [[backend, serverid]]
      end
    end
  end
  
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
  end
end