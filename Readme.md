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
```