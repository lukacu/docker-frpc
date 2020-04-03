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

{{if and .Env.FRPC_ADMIN_USER .Env.FRPC_ADMIN_PWD }}
# set admin address for control frpc's action by http api such as reload (we do not expose this port)
admin_addr = {{ when (not .Env.FRPC_ADMIN_ADDRESS) "127.0.0.1" .Env.FRPC_ADMIN_ADDRESS }}
admin_port = {{ when (not .Env.FRPC_ADMIN_PORT) "7400" .Env.FRPC_ADMIN_PORT }}
admin_user = {{ .Env.FRPC_ADMIN_USER }}
admin_pwd = {{ .Env.FRPC_ADMIN_PWD }}
{{end}}

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
{{ $secret_key := index $container.Labels (printf "frp.%s.secret" $address.Port) }}
{{ $subdomain := index $container.Labels (printf "frp.%s.http.subdomain" $address.Port) }}
{{ $domains := index $container.Labels (printf "frp.%s.http.domains" $address.Port) }}
{{ $rewrite := index $container.Labels (printf "frp.%s.http.rewrite" $address.Port) }}
{{ $httpuser := index $container.Labels ( printf "frp.%s.http.username" $address.Port) }}
{{ $httppwd := index $container.Labels ( printf "frp.%s.http.password" $address.Port) }}
{{ $healthcheck := index $container.Labels ( printf "frp.%s.health_check" $address.Port) }}
{{ $healthcheck := when ( or (or (eq $healthcheck "") (eq $healthcheck "true" )) (or (eq $healthcheck "True" ) (eq $healthcheck "1" )) )  true false }}

{{ if $service_type }}

[{{ print $prefix "_" $name "_" $address.Port }}]

type = {{ $service_type }}
local_ip = {{ $network.IP }}
local_port = {{ $address.Port }}

{{ if $healthcheck }}
health_check_type = {{ $service_type }}
health_check_timeout_s = 3
health_check_interval_s = 60
{{ end }}

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
{{ if eq $service_type "stcp" }}
sk = {{ $secret_key }}

{{ else }}
# Allocate random free port
remote_port = 0
{{ end }}
{{ end }}

{{ end }}
{{ end }}
{{ end }}
{{ end }}
{{ end }}

