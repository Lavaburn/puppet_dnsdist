# Class: dnsdist::params
# defaults.

class dnsdist::params {
  $version          = '13'
  $webserver        = '0.0.0.0:80'
  $webserver_pass   = 'geheim'
  $api_enabled      = false
  $api_pass         = 'geheim'
  $control_socket   = '127.0.0.1'
  $listen_addresess = '0.0.0.0'   # TODO: ARRAY
  $cache_enabled    = false
  $cache_size       = 10000
  $metrics_enabled  = false
  $metrics_host     = '127.0.0.1'
}
