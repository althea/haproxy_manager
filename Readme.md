HaProxy Manager
===============

Haproxy provides ways to add and remove servers on the fly and a lot of other things. This gem lets you use that via a nice ruby API, so that it can be used in applications for deployments testing and gathering statistics.

This was extracted out of our rolling deployment scheme.

Prerequsites
=============

For this to work haproxy 

* Version 1.4 and above

* Should be running with the following configuration.

  `stats socket /home/ubuntu/haproxysock level admin`

  It means that haproxy will open a socket at /home/ubuntu/haproxysock. You can specify the level to use. We use `admin`. But I believe operator/admin is needed for the enable/disable/setting weights to work correctly.

Installation
==============
  Install the latest version of the gem with the following command...

      $ gem install haproxy_manager

      require "haproxy_manager"

  # Gemfile in Rails app

      gem "haproxy_manger", :require => false

  Add the following where approporiate(eg. deploy.rb)
      require "haproxy_manager"

API
======
```Ruby

haproxy = HAProxyManager.new ('path to haproxy socket')

haproxy.backends # Lists all the backends available
haproxy.servers("foo-farm")  # List all the servers available in the given backend

haproxy.disable("preprod-app", "foo-farm") # Disables a server in a specific farm
haproxy.disable("preprod-app") # Disables a server with a given name in all the available backends


haproxy.enable("preprod-app", "foo-farm") # Enables a server in a specific farm
haproxy.enable("preprod-app") # Enables a server with a given name in all the available backends

haproxy.weight("preprod-app", "foo-farm", "10") # Sets the weight to 10. The value can be between 0 - 255
haproxy.weight("preprod-app", "foo-farm", "10%") # Reduces the weight of the server by 10%(of the value specified in the config)
haproxy.weight("preprod-app", "foo-farm", "0%") # Reduces the weight of the server to 0. Useful for disabling the server.
haproxy.weight("preprod-app", "foo-farm", "100%") # Increases the weight to the original configuration value. useful to bring the server back up after reducing the weight to 0%

haproxy.weight("preprod-app", "foo-farm") # Returns the current weights setting. The response is something like this.
{current => 10, initial=> 12}


haproxy.info # provides information about the haproxy setup. The following is how it looks like. Most fields are self describing.
{"Name" =>  "HAProxy", "Version" =>  "1.5-dev11", "Release_date" =>  "2012/06/04", "Nbproc" =>  "1", "Process_num" =>  "1", "Pid" =>  "4084", "Uptime" =>  "58d 3h50m53s", "Uptime_sec" => "5025053", "Memmax_MB" =>  "0", "Ulimit-n" =>  "40029", "Maxsock" =>  "40029", "Maxconn" =>  "20000", "Hard_maxconn" =>  "20000", "Maxpipes" => "0", "CurrConns" => "0", "PipesUsed" => "0", "PipesFree" => " 0", "ConnRate" => " 0", "ConnRateLimit" => " 0", "MaxConnRate" => " 69", "Tasks" => " 10", "Run_queue" => " 1", "Idle_pct" => "100", "node" => " The server name", "description" => "Our Awesome Load balancer"}

haproxy.reset_counters # Clears HAProxy counters. Except Global counters
haproxy.reset_counters(:all) # Clears All HAProxy counters. This is the equivalent of a restart

haproxy.stats # Retrives the HAProxy stats from the server. The result looks something like this.

{"foo-farm"=>{"FRONTEND"=>{"qcur"=>"", "qmax"=>"", "scur"=>"0", "smax"=>"150", "slim"=>"2000", "stot"=>"165893", "bin"=>"38619996", "bout"=>"3233457381", "dreq"=>"0", "dresp"=>"0", "ereq"=>"6504", "econ"=>"", "eresp"=>"", "wretr"=>"", "wredis"=>"", "status"=>"OPEN", "weight"=>"", "act"=>"", "bck"=>"", "chkfail"=>"", "chkdown"=>"", "lastchg"=>"", "downtime"=>"", "qlimit"=>"", "pid"=>"1", "iid"=>"1", "sid"=>"0", "throttle"=>"", "lbtot"=>"", "tracked"=>"", "type"=>"0", "rate"=>"0", "rate_lim"=>"0", "rate_max"=>"69", "check_status"=>"", "check_code"=>"", "check_duration"=>"", "hrsp_1xx"=>"0", "hrsp_2xx"=>"136147", "hrsp_3xx"=>"2128", "hrsp_4xx"=>"6654", "hrsp_5xx"=>"20955", "hrsp_other"=>"9", "hanafail"=>"", "req_rate"=>"0", "req_rate_max"=>"144", "req_tot"=>"165893", "cli_abrt"=>nil, "srv_abrt"=>nil}, "preprod-app"=>{"qcur"=>"0", "qmax"=>"9", "scur"=>"0", "smax"=>"60", "slim"=>"60", "stot"=>"139066", "bin"=>"34839081", "bout"=>"3222850212", "dreq"=>"", "dresp"=>"0", "ereq"=>"", "econ"=>"3", "eresp"=>"725", "wretr"=>"0", "wredis"=>"0", "status"=>"UP", "weight"=>"10", "act"=>"1", "bck"=>"0", "chkfail"=>"583", "chkdown"=>"148", "lastchg"=>"10893", "downtime"=>"257935", "qlimit"=>"", "pid"=>"1", "iid"=>"1", "sid"=>"1", "throttle"=>"", "lbtot"=>"114847", "tracked"=>"", "type"=>"2", "rate"=>"0", "rate_lim"=>"", "rate_max"=>"88", "check_status"=>"L7OK", "check_code"=>"200", "check_duration"=>"150", "hrsp_1xx"=>"0", "hrsp_2xx"=>"135827", "hrsp_3xx"=>"2128", "hrsp_4xx"=>"147", "hrsp_5xx"=>"230", "hrsp_other"=>"0", "hanafail"=>"0", "req_rate"=>"", "req_rate_max"=>"", "req_tot"=>"", "cli_abrt"=>"20", "srv_abrt"=>"11"}, "preprod-bg"=>{"qcur"=>"0", "qmax"=>"0", "scur"=>"0", "smax"=>"3", "slim"=>"30", "stot"=>"31", "bin"=>"14333", "bout"=>"380028", "dreq"=>"", "dresp"=>"0", "ereq"=>"", "econ"=>"0", "eresp"=>"9", "wretr"=>"4", "wredis"=>"2", "status"=>"DOWN", "weight"=>"5", "act"=>"1", "bck"=>"0", "chkfail"=>"4", "chkdown"=>"10", "lastchg"=>"2538799", "downtime"=>"4603702", "qlimit"=>"", "pid"=>"1", "iid"=>"1", "sid"=>"2", "throttle"=>"", "lbtot"=>"6", "tracked"=>"", "type"=>"2", "rate"=>"0", "rate_lim"=>"", "rate_max"=>"2", "check_status"=>"L4CON", "check_code"=>"", "check_duration"=>"0", "hrsp_1xx"=>"0", "hrsp_2xx"=>"16", "hrsp_3xx"=>"0", "hrsp_4xx"=>"0", "hrsp_5xx"=>"0", "hrsp_other"=>"0", "hanafail"=>"0", "req_rate"=>"", "req_rate_max"=>"", "req_tot"=>"", "cli_abrt"=>"1", "srv_abrt"=>"0"}, "preprod-test"=>{"qcur"=>"0", "qmax"=>"0", "scur"=>"0", "smax"=>"0", "slim"=>"30", "stot"=>"0", "bin"=>"0", "bout"=>"0", "dreq"=>"", "dresp"=>"0", "ereq"=>"", "econ"=>"0", "eresp"=>"0", "wretr"=>"0", "wredis"=>"0", "status"=>"DOWN", "weight"=>"5", "act"=>"1", "bck"=>"0", "chkfail"=>"0", "chkdown"=>"1", "lastchg"=>"5102839", "downtime"=>"5102839", "qlimit"=>"", "pid"=>"1", "iid"=>"1", "sid"=>"3", "throttle"=>"", "lbtot"=>"0", "tracked"=>"", "type"=>"2", "rate"=>"0", "rate_lim"=>"", "rate_max"=>"0", "check_status"=>"L4CON", "check_code"=>"", "check_duration"=>"0", "hrsp_1xx"=>"0", "hrsp_2xx"=>"0", "hrsp_3xx"=>"0", "hrsp_4xx"=>"0", "hrsp_5xx"=>"0", "hrsp_other"=>"0", "hanafail"=>"0", "req_rate"=>"", "req_rate_max"=>"", "req_tot"=>"", "cli_abrt"=>"0", "srv_abrt"=>"0"}, "BACKEND"=>{"qcur"=>"0", "qmax"=>"84", "scur"=>"0", "smax"=>"150", "slim"=>"200", "stot"=>"159082", "bin"=>"38619996", "bout"=>"3233457381", "dreq"=>"0", "dresp"=>"0", "ereq"=>"", "econ"=>"19991", "eresp"=>"734", "wretr"=>"4", "wredis"=>"2", "status"=>"UP", "weight"=>"10", "act"=>"1", "bck"=>"0", "chkfail"=>"", "chkdown"=>"148", "lastchg"=>"10893", "downtime"=>"300268", "qlimit"=>"", "pid"=>"1", "iid"=>"1", "sid"=>"0", "throttle"=>"", "lbtot"=>"114853", "tracked"=>"", "type"=>"1", "rate"=>"0", "rate_lim"=>"", "rate_max"=>"144", "check_status"=>"", "check_code"=>"", "check_duration"=>"", "hrsp_1xx"=>"0", "hrsp_2xx"=>"135843", "hrsp_3xx"=>"2128", "hrsp_4xx"=>"147", "hrsp_5xx"=>"20955", "hrsp_other"=>"9", "hanafail"=>"", "req_rate"=>"", "req_rate_max"=>"", "req_tot"=>"", "cli_abrt"=>"21", "srv_abrt"=>"11"}}}



```