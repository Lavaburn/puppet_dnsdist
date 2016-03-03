# Class: dnsdist
#
# This class installs and manages dnsdist
#
# Author
#   Michiel Piscaer <m.piscaer@edutel.nl
#
# Version
#   0.1   Initial release
#
# Parameters:
#
#
# Requires:
#   Nothing.
#
# Sample Usage:
#
# dnsdist
class dnsdist ($webserver = '0.0.0.0:80', $webserver_pass = 'geheim', $control_socket = '127.0.0.1', $listen_addresess = '0.0.0.0') {
  apt::pin { 'dnsdist':
    origin   => 'repo.powerdns.com',
    priority => '600'
  }

  apt::key { 'powerdns':
    key         => '0xFD380FBB',
    key_content => template('dnsdist/aptkey.erb'),
  }

  apt::source { 'repo.powerdns.com':
    location    => 'http://repo.powerdns.com/ubuntu',
    repos       => 'main',
    release     => 'trusty-dnsdist-master',
    include_src => false,
    amd64_only  => true,
    require     => [Apt::Pin['dnsdist'], Apt::Key['powerdns']];
  }

  package { 'dnsdist':
    ensure  => present,
    require => [Apt::Source['repo.powerdns.com']];
  }

  concat { "/etc/dnsdist/dnsdist.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['dnsdist'],
    require => [Package['dnsdist']]
  }

  concat::fragment { "global-header":
    target  => "/etc/dnsdist/dnsdist.conf",
    content => template('dnsdist/dnsdist.conf-header.erb'),
    order   => '10';
  }

  concat::fragment { "acl-header":
    target  => "/etc/dnsdist/dnsdist.conf",
    content => 'setACL({',
    order   => '40';
  }

  concat::fragment { "acl-footer":
    target  => "/etc/dnsdist/dnsdist.conf",
    content => "})\n",
    order   => '49';
  }

  service { 'dnsdist':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [Concat['/etc/dnsdist/dnsdist.conf']]
  }
}