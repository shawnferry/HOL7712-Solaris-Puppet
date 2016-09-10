# 002-better/site.pp

# Copy zshrc from the lab module instead of using the 'content' parameter
file { '/root/.zshrc':
  ensure => present,
  owner  => 'root',
  group  => 'root',
  source => 'puppet:///modules/lab/zshrc';
}

# 003-publisher/site.pp
# Serve a pre-existing solaris package repo on port 1111

# Create the repositories filesystem and mount it at /repositories
# In the lab /rpool/repositories will already exist this will only change the
# mountpoint. We have also pre-cached a small number of packages
zfs { 'rpool/repositories':
  ensure     => present,
  mountpoint => '/repositories';
}

$lab_pkg = hiera('lab::pkg',undef)
# Configure the publisher for the lab
pkg_publisher { 'solaris':
  origin  => [
    '/repositories/publisher/solaris',
    $lab_pkg['solaris']['origin']
  ],
  require => Zfs['rpool/repositories'];
}

# Configure pkg.repod to serve our partial copy of the repo
svccfg {
  # See svc:/application/pkg/mirror:default
  # for an automated service to maintain a true local mirror
  'svc:/application/pkg/server:default/:properties/pkg/inst_root':
    value   => '/repositories/publisher/solaris',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];

  # port 80 is the default nothing will change here
  'svc:/application/pkg/server:default/:properties/pkg/port':
    value   => '80',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];
}

service { 'svc:/application/pkg/server:default':
  ensure => running
}
