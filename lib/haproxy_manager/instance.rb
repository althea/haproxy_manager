require 'socket'
module HAProxyManager
  class Instance
    attr_reader :backends, :backend_instances

    def initialize(socket)
      @socket = HAPSocket.new(socket)
      @print_response = Proc.new {|response| puts response}

    end

    # given a list of socket files, return a hash of Instances with the filename as keys
    def self.create_instances(sockets=[])
      instances = {}
      sockets.each do | socket |
        begin
          instances[socket] = HAProxyManager::Instance.new(socket)
        rescue exception => e
          # Can't open the socket for whatever reason so just skip to the next
          next
        end
      end
      instances
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

    # rereads the backend data each time when refresh is true
    def backend_instances(refresh=false)
      if @backend_instances.nil? or refresh
        @backend_instances = {}
        backend_data = @socket.execute( "show stat -1 4 -1" )[1..-1].collect{|item| item.split(",")[0..1]}
        backend_servers = backend_data.inject({}){|hash, items|
          (hash[items[0]] ||=[]) << items[1]; hash
        }
        backend_servers.each do |backend, servers|
          @backend_instances[backend] = HAProxyManager::Backend.new(backend, @socket)
        end
      end
      @backend_instances
    end

    # This is actually redundant data kept here for backwards compatibility
    # You should really be using backend_instances now
    def backends
      # Lets cache the values and return the cache
      if @backends.nil?
        @backends = {}
        backend_instances.each do | name, backend|
          @backends[name] = backend.servers
        end
      end
      @backends
    end

    def info
      @socket.execute( "show info").inject({}){|hash, item|
        x = item.split(":")
        key = x[0].strip if ! x[0].nil?
        value ||= x[1]|| ""
        hash.merge(key => value.strip)
      }
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

    def stats
      stats = @socket.execute( "show stat -1 -1 -1" )
      headers = stats[0].split(",")
      stats[1..-1].inject({}) do |hash, line|
        data = line.split(","); backend = data[0]; server = data[1]; rest = data[2..-1]
        hash[backend] = {} if( hash[backend].nil?)
        hash[backend][server] = {}.tap do |server_hash|
          headers[2..-1].each_with_index{|x, i| server_hash[x]= rest[i]}
        end
        hash
      end
    end

    # returns an array of servers
    def servers(backend = nil)
      servers = []
      if backend.nil?
        # return all servers
        backend_instances.each_value do | backend|
          servers << backend.servers
        end
      else
        begin
          servers = backend_instances[backend].servers
        rescue KeyError => e
           "The backend #{backend} is not a valid argument"
        end
      end
      return servers.flatten
    end

    # resets Haproxy counters. If no option is specified backend and frontend counters are cleared, but
    # cumulative counters are not cleared. The cumulative counters can be cleared by passing the option of
    # :all to the method, in that case all the counters are cleared. This is similar to a restart.
    # This is useful to reset stats after for example an incident.
    def reset_counters(option = "")
      @socket.execute "clear counters {option}", &@print_response
    end

    private
    # returns array will all backends the server belongs to
    def all_servers(serverid, backend)
      # return all backends the serverid belongs to
      if backend.nil? or ! backend_instances[backend].has_server?(serverid)
        items = []
        backend_instances.each do |name, backend|
          next if ! backend.has_server?(serverid)
          items << [name, serverid]
        end
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