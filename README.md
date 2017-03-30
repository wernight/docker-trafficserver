Supported tags and respective `Dockerfile` links
================================================

  * [`latest` (Dockerfile)](https://github.com/wernight/docker-trafficserver/blob/master/Dockerfile) [![](https://images.microbadger.com/badges/image/wernight/trafficserver.svg)](https://microbadger.com/images/wernight/trafficserver "Get your own image badge on microbadger.com")


What is Apache Traffic Server
-----------------------------

The [**Apache Traffic Server**](https://trafficserver.apache.org/) (ATS) is a modular, high-performance reverse proxy and forward proxy server, generally comparable to Nginx and Squid.
It's used in production to serve more than 30 billion objects per day on sites like the Yahoo! homepage, and Yahoo! Sports, Mail and Finance.

Features:

  * Acts as an [origin server or forward/transparent/reverse proxy](https://docs.trafficserver.apache.org/en/latest/getting-started/index.en.html#terminology) for 
  * Caching
  * Supports WebSocket, some of HTTP/2
  * Authentication and limiting accessible resources

An alternative is [Squid](https://hub.docker.com/r/wernight/squid/) which is simpler to configure but doesn't support `ws://`.


Usage example
-------------

    $ docker run -d -p 8080:8080 wernight/trafficserver

You may run `traffic_ctl` command inside that container to configure it at runtime, or
mount [`/usr/local/etc/trafficserver/records.config`](https://docs.trafficserver.apache.org/en/latest/admin-guide/configuring-traffic-server.en.html)
(there are also [other configuration files](https://docs.trafficserver.apache.org/en/latest/admin-guide/files/index.en.html)).

See [Traffic Server Manual](https://docs.trafficserver.apache.org/en/latest/) for configuration optionas
(by default is should have default settings with some comments).

To diagnose issues, you'll find logs under `/usr/local/var/log/trafficserver/`.


### Forward proxy

For example to set it up as a
[**forward proxy**](https://docs.trafficserver.apache.org/en/latest/admin-guide/configuration/transparent-forward-proxying.en.html?highlight=forward)
create and mount `records.config` with:

    CONFIG proxy.config.url_remap.remap_required INT 0
    CONFIG proxy.config.reverse_proxy.enabled INT 0

### Authentication

To require [**authentication**](https://docs.trafficserver.apache.org/en/latest/admin-guide/plugins/authproxy.en.html) add to `records.config`:

    CONFIG proxy.config.url_remap.remap_required INT 1
    CONFIG proxy.config.http.doc_in_cache_skip_dns INT 0

... and to `remap.config` something like:

    map http://example.com/ http://example.com/ @plugin=authproxy.so \
        @pparam=--auth-transform=redirect @pparam=--auth-host=127.0.0.1 @pparam=--auth-port=9000

    map http://127.0.0.1:9000 http://127.0.0.1:9000

... and have a server listening on http://127.0.0.1:9000 to handle authorization.
For example an Nginx with a configuration like:

    server {
        listen 9000;
        server_name  _;
        location / {
            auth_basic 'ALC';
            # A file created with htpasswd.
            auth_basic_user_file /var/run/secrets/proxy-passwd/passwd;
            # Just return 200 for authenticated users.
            try_files /index.html =200;
        }
    }

Alternatively, you can compile a plugin like [`basic_auth.c`](https://docs.trafficserver.apache.org/en/latest/developer-guide/plugins/example-plugins/basic-authorization/index.en.html) available also on [GitHub](https://github.com/apache/trafficserver/tree/master/example/basic_auth).


### Client-side usage

Then use it for example like:

    $ curl --proxy http://localhost:8080 http://example.com/


Feedbacks
---------

Suggestions are welcome on our [GitHub issue tracker](https://github.com/wernight/docker-trafficserver/issues).
