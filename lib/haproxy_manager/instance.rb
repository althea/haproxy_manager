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
    # A disabled server shows up as in Maintance mode.
    def disable(serverid, backend = nil)
      all_servers(serverid, backend).each do |item|
        @socket.execute "disable server #{item[0]}/#{item[1]}", &@print_response
      end
    end

    # Enables a server in the server in a backend.
    # If backend is not specified then all the backends in which the serverid exists are enabled.
    def enable(serverid, backend = nil)
      all_servers(serverid, backend).each do |item|
        @socket.execute "enable server #{item[0]}/#{item[1]}", &@print_response
      end
    end

    def backends
      @backends.keys
    end

    def info
      @socket.execute( "show info").inject({}){|hash, item| x = item.split(":"); hash.merge(x[0].strip =>  x[1].strip)}
    end

    # Sets weight for the server. If a numeric value is provider, that will become the absolute weight. It can be between 0 -256
    # If a weight has been provided ending with % then the weight is reduced by that percentage. It has to be between 0% - 100%
    # Weight of a server defines, how many requests are passed to it.
    def weights(server, backend, weight=nil)
      if(weight.nil?)
        weight = @socket.execute "get weight #{backend}/#{server}"
        /(\d*)\s\(initial\s(\d*)\)/.match( weight[0])
        {:current => $1.to_i, :initial => $2.to_i}
      else
        @socket.execute "set weight #{backend}/#{server} #{weight}"
      end
    end

    def stats(server, backend)
    #   TODO
    end

    def servers(backend = nil)
      backend.nil? ? @backends.values.flatten : @backends[backend]
    end

    # resets Haproxy counters. If no option is specified backend and frontend counters are cleared, but
    # cumulative counters are not cleared. The cumulative counters can be cleared by passing the option of
    # :all to the method, in that case all the counters are cleared. This is similar to a restart.
    # This is useful to reset stats after for example an incident.
    def reset_counters(option = "")
      @socket.execute "clear counters {option}", &@print_response
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