module HAProxyManager
  class Backend
      attr_reader :name, :servers, :socket

      def initialize(backend_name, socket_conn)
        @name    = backend_name
        @print_response = Proc.new {|response| puts response}
        @socket = socket_conn
        @servers = {}
      end

      def server_names
        servers.keys
      end

      def count
        servers.length
      end

      def servers
        if @servers.length < 1
          srv_names = stats.keys - ['FRONTEND', 'BACKEND']
          srv_names.each do | srv|
            @servers[srv] = Server.new(srv, socket)
          end
        end
        @servers
      end

      def has_server?(name)
        servers.include?(name)
      end

      def method_missing(method, *args, &block)
        if not backend_stats.has_key?(method.to_s)
          raise NoMethodError
        else
          backend_stats[method.to_s]
        end
      end

      def stats_to_json
        JSON.pretty_generate(stats)
      end

      def backend_stats
        stats['BACKEND']
      end

      def frontend_stats
        stats['FRONTEND']
      end

      def stats
        mystats = {}
        stats_data = socket.execute( "show stat -1 -1 -1" )
        headers = stats_data[0].split(",").collect do |name|
          name.gsub('#', '').strip
        end
        stats_data[1..-1].inject({}) do |hash, line|
          data = line.split(",")
          if data.first == name
            i = 0
            datahash = {}
            data.each do |item|
              header = headers[i]
              datahash[header] = item
              i = i + 1
            end
            sv_name = datahash['svname']
            mystats[sv_name] = datahash
          end

        end
        mystats
      end

      def up?
         status == 'UP'
      end

      def down?
        status == 'DOWN'
      end

      def disable
         servers.each do |key, server|
           server.disable
         end
      end

      def enable
        servers.each do |key, server|
          server.enable
        end
      end

      def status
        backend_stats['status']
      end

      def stats_names
        stats.keys
      end
  end
end
