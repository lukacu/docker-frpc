# Generated automatically by docker-gen

[common]
server_addr = {{ when (not .Env.FRPC_SERVER_ADDRESS) "127.0.0.1" .Env.FRPC_SERVER_ADDRESS }}
server_port = {{ when (not .Env.FRPC_SERVER_PORT) "7000" .Env.FRPC_SERVER_PORT }}

{{if .Env.FRPC_LOGFILE }}
log_file = {{ .Env.FRPC_LOGFILE }}

# trace, debug, info, warn, error
log_level = {{ when (not .Env.FRPC_LOG_LEVEL) "warn" .Env.FRPC_LOG_LEVEL }}

log_max_days = {{ when (not .Env.FRPC_LOG_DAYS) "5" .Env.FRPC_LOG_DAYS }}
{{end}}

token =  {{ when (not .Env.FRPC_AUTH_TOKEN) "abcdefghi" .Env.FRPC_AUTH_TOKEN }}

# set admin address for control frpc's action by http api such as reload (we do not expose this port)
admin_addr = 127.0.0.1
admin_port = 7400
admin_user = admin
admin_pwd = admin

# connections will be established in advance, default value is zero
pool_count = {{ when (not .Env.FRPC_POOL_COUNT) "5" .Env.FRPC_POOL_COUNT }}
tcp_mux = {{ when (not .Env.FRPC_TCP_MUX) "true" .Env.FRPC_TCP_MUX }}

login_fail_exit = false

tls_enable = true

{{ $prefix := when (not .Env.FRPC_PREFIX) "frp" .Env.FRPC_PREFIX }}

{{ $work_network := when (not .Env.FRPC_NETWORK) "default" .Env.FRPC_NETWORK }}

{{ range $container := whereLabelValueMatches $ "frp.enabled" "true" }}

{{ if $container.Networks }}
{{ $network := first (where $container.Networks "Name" $work_network ) }}

{{ if ($network) }}

{{ $name := $container.Name }}
{{ $id := $container.ID }}

{{ range $address := $container.Addresses }}

{{ $service_type := index $container.Labels (printf "frp.%s" $address.Port) }}
{{ $subdomain := index $container.Labels (printf "frp.%s.http.subdomain" $address.Port) }}
{{ $domains := index $container.Labels (printf "frp.%s.http.domains" $address.Port) }}
{{ $rewrite := index $container.Labels (printf "frp.%s.http.rewrite" $address.Port) }}
{{ $httpuser := index $container.Labels ( printf "frp.%s.http.username" $address.Port) }}
{{ $httppwd := index $container.Labels ( printf "frp.%s.http.password" $address.Port) }}

{{ if $service_type }}

[{{ print $prefix "_" $name "_" $address.Port }}]

type = {{ $service_type }}
local_ip = {{ $network.IP }}
local_port = {{ $address.Port }}

health_check_type = {{ $service_type }}
health_check_timeout_s = 3
health_check_interval_s = 60

{{ if eq $service_type "http" }}

{{ if and $httpuser $httppwd }}
http_user = {{ $httpuser }}
http_pwd = {{ $httppwd }}
{{ end }}

{{ if $subdomain }}
subdomain = {{ $subdomain }}
{{ end }}

{{ if $domains }}
custom_domains = {{ $domains }}
{{ end }}

{{ if $rewrite }}
host_header_rewrite = {{ $rewrite }}
{{ end }}

health_check_url = /

{{ else }}
# Allocate random free port
remote_port = 0
{{ end }}

{{ end }}
{{ end }}
{{ end }}
{{ end }}
{{ end }}

