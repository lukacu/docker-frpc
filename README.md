Docker container for automatically configuring FRP client using docker-gen.

Environment configuration:

 * `FRPC_SERVER_ADDRESS` - connect to FRP server address, defaults to 127.0.0.1
 * `FRPC_SERVER_PORT` - connect to FRP server port, defaults to 7000
 * `FRPC_AUTH_TOKEN` - token for authentication with the server, defaults to "abcdefghi"
 * `FRPC_MAX_PORTS` - max ports per client, defaults to unlimited
 * `FRPC_POOL_COUNT` - how many connections to open in advance, defaults to 5
 * `FRPC_TCP_MUX` - TCP multiplexing, defaults to true
 * `FRPC_PREFIX` - prefix used when naming connections
 * `FRPC_NETWORK` - which docker network to scan (the FRP client container should also be on this network)
 * `FRPC_LOGFILE` - where to log status (log disabled if not set)
 * `FRPC_LOG_LEVEL` - level of logging, defaults to "warn"
 * `FRPC_LOG_DAYS` - log for how many days, defaults to 5 days

The container should be configured to have a read-only connection to the Docker process socket. It listens for changes in
other containers and will reconfigure the FRP client if changes occur.

The container will detect containers that have the label `frp.enabled` set to "true". It will then scan through their published ports and look for ports that are configured using labels.
The `fpr.<port>` label should be set to either "tcp" or "http" to indicate the type of connection. For HTTP connections the follwing configuration can be set:

 * `fpr.<port>.http.subdomain` - a subdomain to use (the super-domain is set in FRP server configuration)
 * `fpr.<port>.http.domains` - custom domains to use, comma separated
 * `fpr.<port>.http.rewrite` - rewrite Host when sending request to the proxied server
 * `fpr.<port>.http.username` - username for Basic HTTP authentication
 * `fpr.<port>.http.password` - password for Basic HTTP authentication
