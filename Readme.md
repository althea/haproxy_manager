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

  It means that haproxy will open a socket at /home/ubuntu/haproxysock. You can specify the level. We use `admin`.


