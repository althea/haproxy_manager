require 'json'
module HAProxyManager
  class Server
    attr_reader :backends, :name, :status, :socket
    attr_accessor :weight

    def initialize(server_name, socket_conn)
      @name    = server_name
      @socket  = socket_conn
      @print_response = Proc.new {|response| puts response}
    end

    # returns a array of backend names
    def backends
       stats.collect do | key, value|
         value['pxname']
       end
    end

    def stat_names
      stats.each do | key, value|
        return value.keys
      end
    end

    # returns boolean if the the server is in the named backend
    def has_backend?(backend)
      backends.include?(backend)
    end

    # Diables a server in the server in a backend for maintenance.
    # If backend is not specified then all the backends in which the serverid exists are disabled.
    # A disabled server shows up as in Maintance mode.
    def disable(backend = nil)
      if backend.nil?
        mybackends = backends.flatten
      else
        if has_backend?(backend)
          mybackends = [backend]
        else
          mybackends = []
        end
      end
      mybackends.each do |backen|
        @socket.execute "disable server #{backen}/#{name}", &@print_response
      end
    end

    # Enables a server in the server in a backend.
    # If backend is not specified then all the backends in which the serverid exists are enabled.
    def enable(backend = nil)
      if backend.nil?
        mybackends = backends.flatten
      else
        if has_backend?(backend)
          mybackends = [backend]
        else
          mybackends = []
        end
      end
      mybackends.each do |backen|
        @socket.execute "enable server #{backen}/#{name}", &@print_response
      end
    end

    # get the status of the server for just one backend
    # If all backends marked the server as down, the status will be down, otherwise up
    # Note: this does not account for servers in maint mode
    def status(backend)
      if backend.nil? or ! has_backend?(backend)
        raise 'InvalidBackendName'
      else
         stats["#{backend}/#{name}"].fetch('status')
      end
    end

    # returns boolean if the server is up in all backends.  Passing a backend will return boolean if up is in
    # the specified backend
    def up?(backend)
      status(backend) == 'UP'
    end

    # returns boolean if the server is down in all backends.  Passing a backend will return boolean if down is in
    # the specified backend
    def down?(backend)
      status(backend) == 'DOWN'
    end

    def maint?(backend)
      status(backend) == 'MAINT'
    end

    def method_missing(method, *args, &block)
      if not stat_names.include?(method.to_s)
        raise NoMethodError
      else
        backend = args.shift
        if backend.nil?
          mybackends = backends.flatten
        else
          if has_backend?(backend)
            mybackends = [backend]
          else
            mybackends = []
          end
        end
        data = {}
        mybackends.each do |backend|
          data["#{backend}/#{method.to_s}"] = stats["#{backend}/#{name}"].fetch(method.to_s)
        end
        data['total'] = total(data)
        data
      end
    end

    # returns the array of weights for all backends or specified backends
    def weight(backend=nil)
      if backend.nil?
        mybackends = backends.flatten
      else
        if has_backend?(backend)
          mybackends = [backend]
        else
          mybackends = []
        end
      end
       mybackends.collect do |backend|
         stats["#{backend}/#{name}"].fetch('weight').to_i
       end
    end

    # Sets weight for the server. If a numeric value is provider, that will become the absolute weight. It can be between 0 -256
    # If a weight has been provided ending with % then the weight is reduced by that percentage. It has to be between 0% - 100%
    # Weight of a server defines, how many requests are passed to it.
    def set_weight( weight, backend=nil)
      if backend.nil?
        mybackends = backends.flatten
      else
        if has_backend?(backend)
          mybackends = [backend]
        else
          mybackends = []
        end
      end
      mybackends.each do | backend|
        @socket.execute "set weight #{backend}/#{name} #{weight}"
      end
    end

    def stats
      mystats = {}
      stats_data = socket.execute( "show stat -1 -1 -1" )
      headers = stats_data[0].split(",").collect do |name|
        name.gsub('#', '').strip
      end
      stats_data[1..-1].inject({}) do |hash, line|
        data = line.split(",")
        # match the svname with the name of this server
        if data[1] == name
          i = 0
          datahash = {}
          data.each do |item|
            header = headers[i]
            datahash[header] = item
            i = i + 1
          end
          sv_name = datahash['svname']
          px_name = datahash['pxname']
          mystats["#{px_name}/#{sv_name}"] = datahash
        end

      end
      mystats
    end

    def stats_to_json
      JSON.pretty_generate(stats)
    end

    private

    def total(hash)
      begin
        hash.values.map(&:to_i).reduce(:+)
      rescue TypeError

      end
    end

  end
end
