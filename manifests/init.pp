# Class: dnsdist
#
# This class installs and manages dnsdist
#
# Author
#   Michiel Piscaer <michiel@piscaer.com>
#
# Version
#   0.1   Initial release
#
# Parameters:
#   $webserver = '0.0.0.0:80',
#   $webserver_pass = 'geheim'
#   $control_socket = '127.0.0.1'
#   $listen_addresess = '0.0.0.0'
#
# Requires:
#   concat
#   apt
#
# Sample Usage:
#
#   class { 'dnsdist':
#    webserver        => '192.168.1.1:80',
#    listen_addresess => [ '192.168.1.1' ];
#  }
#
class dnsdist (
  $version          = $dnsdist::params::version,
  $webserver        = $dnsdist::params::webserver,
  $webserver_pass   = $dnsdist::params::webserver_pass,
  $api_enabled      = $dnsdist::params::api_enabled,
  $api_pass         = $dnsdist::params::api_pass,
  $control_socket   = $dnsdist::params::control_socket,
  $listen_addresess = $dnsdist::params::listen_addresess,
  $cache_enabled    = $dnsdist::params::cache_enabled,
  $cache_size       = $dnsdist::params::cache_size,
  $metrics_enabled  = $dnsdist::params::metrics_enabled,
  $metrics_host     = $dnsdist::params::metrics_host,
  ) inherits dnsdist::params
{
  apt::pin { 'dnsdist':
    origin   => 'repo.powerdns.com',
    priority => '600',
  }

  apt::source { 'repo.powerdns.com':
    location      => 'http://repo.powerdns.com/ubuntu',
    repos         => 'main',
    release       => join([$::lsbdistcodename, '-dnsdist-', $version], ''),
    architecture  => 'amd64',
    key           => {
      id     => '9FAAA5577E8FCF62093D036C1B0C6205FD380FBB',
      server => 'keyserver.ubuntu.com',
    },
    require       => [Apt::Pin['dnsdist']];
  }

  package { 'dnsdist':
    ensure  => present,
    require => [Apt::Source['repo.powerdns.com']];
  }

  concat { '/etc/dnsdist/dnsdist.conf' :
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsdist'],
    require => [Package['dnsdist']],
  }

  concat::fragment { 'global-header':
    target  => '/etc/dnsdist/dnsdist.conf',
    content => template('dnsdist/dnsdist.conf-header.erb'),
    order   => '10';
  }

  concat::fragment { 'acl-header':
    target  => '/etc/dnsdist/dnsdist.conf',
    content => 'setACL({',
    order   => '40';
  }

  concat::fragment { 'acl-footer':
    target  => '/etc/dnsdist/dnsdist.conf',
    content => "})\n",
    order   => '49';
  }

  service { 'dnsdist':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [Concat['/etc/dnsdist/dnsdist.conf']],
  }
}
